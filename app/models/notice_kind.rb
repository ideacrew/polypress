# frozen_string_literal: true

# Stores notice information
class NoticeKind
  include Mongoid::Document
  include Mongoid::Timestamps
  # include AASM
  include NoticeBuilder

  RECIPIENTS = {
    "User" => "User",
    "Consumer" => "ConsumerRole",
    "QLE" => "QualifyingLifeEventKind"
    # "Employee" => "EmployeeProfile",
    # "Broker" => "BrokerProfile",
    # "Broker Agency" => "BrokerAgencyProfile",
    # "GeneralAgency" => "GeneralAgency"
  }.freeze

  MARKET_KINDS = [:aca_individual, :aca_shop].freeze

  field :title, type: String
  field :description, type: String
  field :identifier, type: String
  field :notice_number, type: String
  field :recipient, type: String, default: "::User"
  # field :aasm_state, type: String, default: :draft
  field :event_name, type: String, default: nil
  field :market_kind, type: Symbol, default: :aca_shop

  embeds_one :cover_page
  embeds_one :template, class_name: "Template"
  # embeds_many :workflow_state_transitions, as: :transitional, class_name: "::WorkflowStateTransition"

  validates_presence_of :title, :notice_number, :recipient
  validates_uniqueness_of :notice_number
  validates_uniqueness_of :event_name, :allow_blank => true

  validates :market_kind,
            inclusion: { in: MARKET_KINDS, message: "%<value> is not a valid market kind" },
            allow_nil: false

  before_save :set_data_elements

  # scope :published,         ->{ any_in(aasm_state: ['published']) }
  # scope :archived,          ->{ any_in(aasm_state: ['archived']) }

  scope :shop,              -> { where(:market_kind.ne => :aca_individual) }
  scope :individual,        -> { where(:market_kind => :aca_individual) }

  attr_accessor :resource, :payload

  def tokens
    template.raw_body.scan(/\#\{([\w|.\s+\-]*)\}/).flatten.reject {|element| element.scan(/Settings/).any?}.uniq.map(&:strip)
  end

  def conditional_tokens
    keywords = { 'if' => '', 'else' => '', 'end' => '', 'elsif' => '', 'unless' => '' }
    template.raw_body.scan(/\[\[([\s|\w.?]*)/).flatten.map(&:strip).collect do |ele|
      ele.gsub(/\w+/) do |m|
        keywords.fetch(m, m)
      end
    end.map(&:strip).reject(&:blank?).uniq
  end

  def set_data_elements
    return unless template.present?

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
    template.data_elements = data_elements + iterator_subloop_tokens
  end

  def execute_notice(_event_name, payload)
    # finder_mapping = ApplicationEventMapper.lookup_resource_mapping(event_name)
    # if finder_mapping.nil?
    #   raise ArgumentError.new("BOGUS EVENT...could n't find resoure mapping for event #{event_name}.")
    # end

    @payload = payload
    # @resource = finder_mapping.mapped_class.send(finder_mapping.search_method, payload[finder_mapping.identifier_key.to_s])
    @resource = @payload

    raise ArgumentError, "Bad Payload...could n't find resource." if @resource.blank?

    generate_pdf_notice
    upload_and_send_secure_message
    send_generic_notice_alert
    send_generic_notice_alert_to_broker_and_ga
    store_paper_notice
    clear_tmp
  end

  def recipient_klass_name
    recipient.to_s.split('::').last.underscore.to_sym
  end

  def shop?
    [
      :employer_profile,
      :employee_profile,
      :broker_profile,
      :broker_agency_profile,
      :general_agency
    ].include? recipient_klass_name
  end

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << ['Market Kind', 'Notice Number', 'Title', 'Description', 'Recipient', 'Event Name', 'Notice Template']

      all.each do |notice|
        csv << [notice.market_kind, notice.notice_number, notice.title, notice.description, notice.recipient, notice.event_name,
                notice.template.try(:raw_body)]
      end
    end
  end

  # aasm do
  #   state :draft, initial: true

  #   state :published
  #   state :archived

  #   event :publish, :after => :record_transition do
  #     transitions from: :draft,  to: :published,  :guard  => :can_be_published?
  #   end

  #   event :archive, :after => :record_transition do
  #     transitions from: [:published],  to: :archived
  #   end
  # end

  # Check if notice with same MPI indictor exists
  def can_be_published?
  end

  # def record_transition
  #   self.workflow_state_transitions << WorkflowStateTransition.new(
  #     from_state: aasm.from_state,
  #     to_state: aasm.to_state
  #     )
  # end

  def individual_market?
    market_kind == :aca_individual
  end

  def shop_market?
    market_kind.blank? || market_kind == :aca_shop
  end

  # def self.markdown
  #   Redcarpet::Markdown.new(ReplaceTokenRenderer,
  #       no_links: true,
  #       hard_wrap: true,
  #       disable_indented_code_blocks: true,
  #       fenced_code_blocks: false,
  #     )
  # end

  # # Markdown API: http://www.rubydoc.info/gems/redcarpet/3.3.4
  # def to_html
  #   self.markdown.render(template.body)
  # end
end