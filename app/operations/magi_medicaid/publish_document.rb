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
    IRS_DOCUMENT_LOCAL_PATH = 'aws/irs_1095a'
    IRS_DOCUMENT_LOCAL_ERROR_PATH = 'aws/errors/irs_1095a'
    TAX_DOCUMENTS = ['IVLTAX', 'IVLVTA', 'IVLCAP'].freeze

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

      uploaded_document = yield upload_document(params, documents_hash, recipient_hbx_id)
      event = yield build_event(uploaded_document)
      result = yield publish_response(event)
      Success(result)
    end

    private

    def get_recipient_hbx_id(entity)
      hbx_id =
        if entity.is_a?(AcaEntities::MagiMedicaid::Application)
          primary_app = entity[:applicants].detect { |a| a[:is_primary_applicant] == true } || entity[:applicants][0]
          primary_app[:person_hbx_id]
        elsif entity[:family_members]
          primary_member = entity[:family_members].detect { |a| a[:is_primary_applicant] == true } || entity[:family_members][0]
          primary_member[:person][:hbx_id]
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

    def requires_paper_communication?(params)
      template_model = params[:template_model]
      entity = params[:entity]
      return true if template_model.paper_communication_override

      case entity
      when ::AcaEntities::Families::Family
        primary_member = entity.family_members.detect(&:is_primary_applicant)
        primary_member.present? && primary_member.person.consumer_role.present? &&
          primary_member.person.consumer_role.contact_method.present? &&
          primary_member.person.consumer_role.contact_method.include?('Paper')
      when ::AcaEntities::MagiMedicaid::Application
        entity.notice_options.paper_notification
      else
        true # default to true
      end
    end

    def destination_folder(result, print_code)
      if TAX_DOCUMENTS.include?(print_code)
        result ? IRS_DOCUMENT_LOCAL_PATH : IRS_DOCUMENT_LOCAL_ERROR_PATH
      else
        result ? DOCUMENT_LOCAL_PATH : DOCUMENT_LOCAL_ERROR_PATH
      end
    end

    def upload_document(params, document_payload, resource_id)
      upload =
        Documents::Upload.new.call(
          resource_id: resource_id,
          title: document_payload[:template][:title],
          file: document_payload[:document],
          user_id: nil,
          subjects: nil
        )

      print_code = document_payload[:template][:print_code]
      destination_folder = destination_folder(upload.success?, print_code)

      move_document_to_local(
        params,
        document_payload[:document].path,
        destination_folder
      )

      return Failure("Couldn't upload document for the given payload") unless upload.success?

      Success(upload.success)
    end

    def move_document_to_local(params, document_path, destination_folder)
      return unless requires_paper_communication?(params)

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
