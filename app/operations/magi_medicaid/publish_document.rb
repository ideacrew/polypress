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

    # @param [Hash] AcaEntities::MagiMedicaid::Application or AcaEntities::Families::Family
    # @param [String] :event_key
    # @return [Dry::Monads::Result] Parsed template as string
    def call(params)
      documents_hash = yield create_document_with_inserts(params)
      resource_id = yield fetch_resource_id(params)
      uploaded_document = yield upload_document(documents_hash, resource_id)
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
        unless Rails.env.test?
          logger.error(
            "Couldn't create document for the given payload: #{result.failure}"
          )
        end
        Failure(result.failure)
      end
    end

    def fetch_resource_id(params)
      resource_id =
        if params[:event_key].to_s == 'enrollment_submitted'
          params[:entity].hbx_id
        else
          params[:entity].family_reference.hbx_id
        end

      Success(resource_id)
    end

    def upload_document(document_payload, resource_id)
      upload =
        Documents::Upload.new.call(
          resource_id: resource_id,
          title: document_payload[:template][:title],
          file: document_payload[:document],
          user_id: nil,
          subjects: nil
        )

      return Failure("Couldn't upload document for the given payload") unless upload.success?

      Success(upload.success)
    end

    def build_event(payload)
      result =
        event('events.documents.document_created', attributes: payload.to_h)
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
