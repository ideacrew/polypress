# frozen_string_literal: true

module Publishers
  # Publisher will send response payload to EA
  class DocumentMetaDataPublisher
    # TODO: enable below after eventsource initializer is updated acccordingly to acaentities async_api yml files
    include ::EventSource::Publisher[amqp: 'polypress.document_builder']

    register_event 'document_created'
  end
end
