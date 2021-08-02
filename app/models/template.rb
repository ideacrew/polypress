# frozen_string_literal: true

# A Template contains structured and unstructured text and associated content to be output into a document
class Template
  include Mongoid::Document
  include Mongoid::Timestamps

  CATEGORIES = [:aca_individual].freeze
  DOC_TYPES = [:notice, :insert].freeze

  field :key, type: Symbol
  field :title, type: String
  field :description, type: String
  field :content_type, type: String
  field :recipient, type: String
  field :cc_recipients, type: Array
  field :locale, type: String
  field :contracts, type: Array
  field :body, type: String
  field :subject, type: String
  field :doc_type, type: String
  field :inserts, type: Array, default: []
  field :category, type: String, default: :aca_individual
  # field :tags, type: String

  # validates_presence_of :raw_body

  # before_save :set_data_elements

  def to_s
    [raw_header, raw_body, raw_footer].join('\n\n')
  end

  def data_elements
    return unless body.present?

    conditional_token_loops = []
    iterator_subloop_tokens = []
    loop_tokens = []
    loop_iterators = conditional_tokens.inject([]) do |iterators, conditional_token|
      iterators unless conditional_token.match(/(.+)\.each/i)
      loop_match = conditional_token.match(/\|(.+)\|/i)
      if loop_match.present?
        loop_token = conditional_token.match(/(.+)\.each/i)[1]
        loop_tokens << loop_token
        iterator_subloop_tokens << loop_token if iterators.any? {|iterator| loop_token.match(/^#{iterator}\.(.*)$/i).present? }
        conditional_token_loops << conditional_token
        iterators << loop_match[1].strip
      else
        iterators
      end
    end

    filtered_conditional_tokens = conditional_tokens - conditional_token_loops
    data_elements = (tokens + filtered_conditional_tokens + loop_tokens).reject do |token|
      loop_iterators.any? do |iterator|
        token.match(/^#{iterator}\.(.*)$/i).present? && token.match(/(.+)\.each/i).blank?
      end
    end
    data_elements + iterator_subloop_tokens
  end

  def conditional_tokens
    keywords = { 'if' => '', 'else' => '', 'end' => '', 'elsif' => '', 'unless' => '' }
    body.scan(/\[\[([\s|\w.?]*)/).flatten.map(&:strip).collect do |ele|
      ele.gsub(/\w+/) do |m|
        keywords.fetch(m, m)
      end
    end.map(&:strip).reject(&:blank?).uniq
  end

  def tokens
    body.scan(/\#\{([\w|.\s+\-]*)\}/).flatten.reject {|element| element.scan(/Settings/).any?}.uniq.map(&:strip)
  end

  def document_recipient
    OpenStruct.new(hbx_id: "100009")
  end

  def recipient_klass_name
    recipient.to_s.split('::').last.underscore.to_sym
  end

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << ['Market Kind', 'Notice Number', 'Title', 'Description', 'Recipient', 'Event Name', 'Notice Template', 'Content Type']

      all.each do |template|
        csv << [
          template.category,
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