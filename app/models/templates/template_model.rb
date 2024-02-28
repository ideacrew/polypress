# frozen_string_literal: true

module Templates
  # Mongoid peristance model for {Templates::Template} entity
  class TemplateModel
    include Mongoid::Document
    include Mongoid::Timestamps

    BLOCKED_ELEMENTS = ['<script', '%script', 'iframe', 'file://', 'dict://', 'ftp://', 'gopher://', '%x', 'system', 'exec', 'Kernel.spawn', 'Open3',
                        '`'].freeze

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
    # indicates paper communication must be sent, irrespective of preferences
    field :paper_communication_override, type: Boolean

    embeds_one :publisher,
               inverse_of: :publisher_event,
               class_name: 'EventRoutes::EventRouteModel',
               cascade_callbacks: true

    embeds_one :subscriber,
               inverse_of: :subscriber_event,
               class_name: 'EventRoutes::EventRouteModel',
               cascade_callbacks: true

    embeds_one :body, class_name: 'Bodies::BodyModel', cascade_callbacks: true

    validate :check_template_elements

    accepts_nested_attributes_for :body, :publisher, :subscriber

    DocumentRecipient = Struct.new(:hbx_id)

    # index({ key: 1 }, { unique: true, name: 'key_index' })
    index({ published_at: 1 }, { sparse: true })
    index({ marketplace: 1 })
    index(
      { 'publisher.event_name': 1 },
      { sparse: true, name: 'publisher_index' }
    )
    index(
      { 'subscriber.event_name': 1 },
      { sparse: true, unique: true, name: 'subscriber_index' }
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

    def data_elements
      []
    end

    def self.instant_preview_for(attributes)
      RenderLiquid.new.call(
        {
          body: attributes[:body],
          template:
            Templates::Template.new(
              {
                recipient: attributes[:recipient],
                key: attributes[:key],
                subject: attributes[:subject],
                title: attributes[:title],
                marketplace: attributes[:marketplace],
                body: {
                  markup: attributes[:body]
                }
              }
            ),
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
            if v[:publishers].present?
              protocol = v[:publishers][:protocol]
              routing_key =
                v[:publishers][:bindings][protocol]&.send(:[], :routing_key)

              data[v[:publishers][:description]] = (routing_key || k)
              data
            else
              {}
            end
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

    def document_name_for(prefix)
      [
        prefix,
        title.titleize.gsub(/[^0-9A-Za-z]/, ''),
        print_code,
        'IVL',
        DateTime.now.strftime('%Y%m%d%H%M%S')
      ].compact.join('_').downcase
    end

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
      DocumentRecipient.new(hbx_id: '100009')
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

    def self.build_notice_kind(template_row)
      self.new(
        marketplace: template_row[0],
        print_code: template_row[1],
        title: template_row[2],
        description: template_row[3],
        recipient: template_row[4],
        key: template_row[5],
        body: {
          markup: template_row[6]
        },
        content_type: template_row[7]
      )
    end

    private

    def check_template_elements
      raw_text = [key, title, description].join('\n\n').to_s.downcase
      errors.add(:base, 'has invalid elements') if BLOCKED_ELEMENTS.any? {|str| raw_text.include?(str)}
    end
  end
end
