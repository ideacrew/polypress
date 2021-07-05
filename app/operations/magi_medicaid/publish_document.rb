# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module MagiMedicaid
  # Operation to create template
  class PublishDocument
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])
    send(:include, ::EventSource::Command)
    send(:include, ::EventSource::Logging)

    # @param [Hash] AcaEntities::MagiMedicaid::Application
    # @param [String] :event_key
    # @return [Dry::Monads::Result] Parsed template as string
    def call(params)
      documents_hash = yield create_document_with_inserts(params)
      uploaded_document = yield upload_document(documents_hash, params[:application_entity])
      event = yield build_event(uploaded_document)
      result = yield publish_response(event)
      Success(result)
    end

    private

    # Creates document with inserts
    def create_document_with_inserts(params)
      result = Documents::CreateWithInsert.new.call(params)
      if result.success?
        Success(result.success)
      else
        logger.error("Couldn't create document for the given payload: #{result.failure}") unless Rails.env.test?
        Failure(result.failure)
      end
    end

    def upload_document(document_payload, entity)
      upload = Documents::Upload.new.call(
        resource_id: entity.family_reference.hbx_id,
        title: document_payload[:template][:title],
        file: document_payload[:document],
        user_id: nil,
        subjects: nil
      )

      return Failure("Couldn't upload document for the given payload") unless upload.success?

      Success(upload.success)
    end

    def build_event(payload)
      result = event("events.documents.document_created", attributes: payload.to_h)
      unless Rails.env.test?
        logger.info('-' * 100)
        logger.info(
          "Polypress Reponse Publisher to external systems(enroll),
          event_key: events.documents.document_created, attributes: #{payload.to_h}, result: #{result}"
        )
        logger.info('-' * 100)
      end
      result
    end

    def publish_response(event)
      Success(event.publish)
    end
  end
end
