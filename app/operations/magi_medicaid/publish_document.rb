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

    DOCUMENT_LOCAL_PATH = 'aws/ivl_mwe'
    DOCUMENT_LOCAL_ERROR_PATH = 'aws/errors/ivl_mwe'

    # @param [Hash] AcaEntities::MagiMedicaid::Application or AcaEntities::Families::Family
    # @param [Templates::TemplateModel] :template_model
    # @return [Dry::Monads::Result] Parsed template as string
    def call(params)
      recipient_hbx_id = yield get_recipient_hbx_id(params[:entity])
      document_name = yield build_document_name(params, recipient_hbx_id)
      documents_hash =
        yield create_document_with_inserts(
          params,
          document_name,
          recipient_hbx_id
        )
      resource_id = yield fetch_resource_id(params)
      uploaded_document = yield upload_document(documents_hash, resource_id)
      event = yield build_event(uploaded_document)
      result = yield publish_response(event)
      Success(result)
    end

    private

    def get_recipient_hbx_id(entity)
      hbx_id =
        if entity.respond_to?(:applicants)
          entity[:applicants].detect { |a| a[:is_primary_applicant] == true }[
            :person_hbx_id
          ]
        elsif entity[:family_members]
          entity[:family_members].detect do |a|
            a[:is_primary_applicant] == true
          end[
            :person
          ][
            :hbx_id
          ]
        end

      return Failure('unable to find recipient hbx id') unless hbx_id
      Success(hbx_id)
    end

    def build_document_name(params, recipient_hbx_id)
      template = params[:template_model]

      return Failure('Missing template model') unless template
      document_name = template.document_name_for(recipient_hbx_id)

      Success(document_name)
    end

    # Creates document with inserts
    def create_document_with_inserts(params, document_name, recipient_hbx_id)
      params.merge!(
        recipient_hbx_id: recipient_hbx_id,
        document_name: document_name
      )
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
        if params[:entity].respond_to?(:family_reference)
          params[:entity].family_reference.hbx_id
        else
          params[:entity].hbx_id
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

      destination_folder =
        upload.success? ? DOCUMENT_LOCAL_PATH : DOCUMENT_LOCAL_ERROR_PATH

      move_document_to_local(
        document_payload[:document].path,
        destination_folder
      )

      return Failure("Couldn't upload document for the given payload") unless upload.success?

      Success(upload.success)
    end

    def move_document_to_local(document_path, destination_folder)
      destination_path = Rails.root.join('..', destination_folder)
      FileUtils.mkdir_p destination_path
      FileUtils.mv document_path, destination_path
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
