# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module MagiMedicaid
  # Operation to create template
  class PublishUqhpEligibleDocument
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])
    send(:include, ::EventSource::Command)
    send(:include, ::EventSource::Logging)

    # @param [Hash] AcaEntities::MagiMedicaid::Application
    # @param [String] :event_key
    # @return [Dry::Monads::Result] Parsed template as string
    def call(params)
      template = yield find_template(params)
      document = yield create_document({ id: template.id, entity: params[:application_entity] })
      uploaded_document = yield upload_document(document, params[:application_entity], template)
      event = yield build_event(uploaded_document)
      result = yield publish_response(event)
      Success(result)
    end

    private

    def find_template(params)
      template = Template.where(key: params[:event_key]).first
      if template
        Success(template)
      else
        Failure("No template found for the given #{params[:event_key]} & for resource #{params[:application][:family_reference][:hbx_id]}")
      end
    end

    def create_document(params)
      document = Documents::Create.new.call(params)
      if document.success?
        Success(document.success)
      else
        logger.error("Couldn't create document for the given payload: #{document.failure}") unless Rails.env.test?
        Failure(document.failure)
      end
    end

    def upload_document(document_payload, entity, template)
      upload = Documents::Upload.new.call(
        resource_id: entity.family_reference.hbx_id,
        title: template.title,
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
