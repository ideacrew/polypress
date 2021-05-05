# frozen_string_literal: true

module Publishers
  module MagiMedicaid
    # Responsible for publishing eligibility events
    class EligibilitiesPublisher

      include EventSource::Publisher['magi_medicaid.eligibilities_publisher']

      register_event 'magi_medicaid.uphp_eligible_document_published'
      register_event 'magi_medicaid.aphp_eligible_document_published'
      register_event 'magi_medicaid.magi_medicaid_eligible_document_published'
      register_event 'magi_medicaid.totally_ineligible_document_published'
    end
  end
end