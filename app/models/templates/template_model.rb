# frozen_string_literal: true

module Templates
  # Mongoid peristance model for {Templates::Template} entity
  class TemplateModel
    include Mongoid::Document
    include Mongoid::Timestamps

    field :key, type: String
    field :title, type: String
    field :description, type: String
    field :locale, type: String
    field :marketplace, type: String, default: 'aca_individual'
    field :print_code, type: String
    field :content_type, type: String
    field :published_at, type: DateTime
    field :recipient, type: String
    field :author, type: String
    field :updated_by, type: String

    embeds_one :publisher,
               inverse_of: :publisher_event,
               class_name: 'EventRoutes::EventRouteModel',
               cascade_callbacks: true

    embeds_one :subscriber,
               inverse_of: :subscriber_event,
               class_name: 'EventRoutes::EventRouteModel',
               cascade_callbacks: true

    embeds_one :body, class_name: 'Bodies::BodyModel', cascade_callbacks: true

    accepts_nested_attributes_for :body, :publisher, :subscriber

    index({ key: 1 }, { unique: true, name: 'key_index' })
    index({ published_at: 1 }, { sparse: true })
    index({ marketpalce: 1 })
    index(
      { 'publisher.event_name': 1 },
      { sparse: true, name: 'publisher_index' }
    )
    index(
      { 'subscriber.event_name': 1 },
      { sparse: true, name: 'subscriber_index' }
    )

    scope :all, -> { exists(_id: true) }
    scope :aca_individual_market, -> { where(marketplace: 'aca_individual') }
    scope :aca_shop_market, -> { where(marketplace: 'aca_shop') }
    scope :published, -> { exists(published_at: true) }
    scope :draft, -> { exists(published_at: false) }
    scope :by_key, ->(value) { where(key: value[:value]) }
    scope :by_id, ->(value) { value[:_id] }
    scope :by_publisher,
          ->(value) { where('publisher.event_name': value[:event_name]) }
    scope :by_subscriber,
          ->(value) { where('subscriber.event_name': value[:event_name]) }

    def to_entity
      serializable_hash.merge('_id' => id.to_s).deep_symbolize_keys
    end

    def to_s
      [raw_header, raw_body, raw_footer].join('\n\n')
    end

    # rubocop:disable Metrics/MethodLength
    def data_elements
      return unless body.present?

      conditional_token_loops = []
      iterator_subloop_tokens = []
      loop_tokens = []
      loop_iterators =
        conditional_tokens.inject([]) do |iterators, conditional_token|
          iterators unless conditional_token.match(/(.+)\.each/i)
          loop_match = conditional_token.match(/\|(.+)\|/i)
          if loop_match.present?
            loop_token = conditional_token.match(/(.+)\.each/i)[1]
            loop_tokens << loop_token
            if iterators.any? do |iterator|
                 loop_token.match(/^#{iterator}\.(.*)$/i).present?
               end
              iterator_subloop_tokens << loop_token
            end
            conditional_token_loops << conditional_token
            iterators << loop_match[1].strip
          else
            iterators
          end
        end

      filtered_conditional_tokens = conditional_tokens - conditional_token_loops
      data_elements =
        (tokens + filtered_conditional_tokens + loop_tokens).reject do |token|
          loop_iterators.any? do |iterator|
            token.match(/^#{iterator}\.(.*)$/i).present? &&
              token.match(/(.+)\.each/i).blank?
          end
        end
      data_elements + iterator_subloop_tokens
    end

    def self.instant_preview_for(attributes)
      RenderLiquid.new.call(
        {
          body: attributes[:body],
          template: {
            key: attributes[:key],
            subject: attributes[:subject],
            title: attributes[:title],
            marketplace: attributes[:marketplace],
            body: {
              markup: attributes[:body]
            }
          },
          subject: attributes[:subject],
          key: attributes[:key],
          cover_page: true,
          instant_preview: 'true'
        }
      )
    end

    def publisher_options
      event_map = AcaEntities::AsyncApi::Operations::EventMap.new.call

      if event_map.success?
        event_map
          .success
          .each_with_object({}) do |(k, v), data|
            data[v[:publishers][:description]] = k if v[:publishers].present?
          end
      else
        {}
      end
    end

    def subscriber_options
      event_map = AcaEntities::AsyncApi::Operations::EventMap.new.call

      if event_map.success?
        event_map
          .success
          .each_with_object({}) do |(k, v), data|
            data[v[:subscribeers][:description]] = k if v[:subscribeers]
                                                        .present?
          end
      else
        {}
      end
    end

    # rubocop:enable Metrics/MethodLength

    def conditional_tokens
      keywords = {
        'if' => '',
        'else' => '',
        'end' => '',
        'elsif' => '',
        'unless' => ''
      }
      body.scan(/\[\[([\s|\w.?]*)/).flatten.map(&:strip).collect do |ele|
        ele.gsub(/\w+/) { |m| keywords.fetch(m, m) }
      end.map(&:strip)
          .reject(&:blank?)
          .uniq
    end

    def tokens
      body.scan(/\#\{([\w|.\s+\-]*)\}/).flatten.reject do |element|
        element.scan(/Settings/).any?
      end.uniq.map(&:strip)
    end

    def document_recipient
      OpenStruct.new(hbx_id: '100009')
    end

    def recipient_klass_name
      recipient.to_s.split('::').last.underscore.to_sym
    end

    def self.to_csv
      CSV.generate(headers: true) do |csv|
        csv << [
          'Marketplace',
          'Notice Number',
          'Title',
          'Description',
          'Recipient',
          'Event Name',
          'Notice Template',
          'Content Type'
        ]

        all.each do |template|
          csv << [
            template.marketplace,
            template.print_code,
            template.title,
            template.description,
            template.recipient,
            template.key,
            template.body.markup,
            template.content_type
          ]
        end
      end
    end
  end
end
