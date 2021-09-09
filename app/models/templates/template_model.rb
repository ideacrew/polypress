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
    field :print_code, type: String

    field :content_type, type: String
    field :marketplace, type: String

    field :markup_section, type: String

    field :author, type: String
    field :updated_by, type: String

    # embeds_one :body, as: :template_body

    index({ key: 1 }, { unique: true, name: 'key_index' })

    def to_entity
      # self.serializable_hash(except: %w[_id])
      self.serializable_hash
    end

    def to_s
      [raw_header, raw_body, raw_footer].join('\n\n')
    end

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
            template.subject,
            template.title,
            template.description,
            template.recipient,
            template.key,
            template.body,
            template.content_type
          ]
        end
      end
    end
  end
end
