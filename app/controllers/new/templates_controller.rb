# frozen_string_literal: true

module New
  # TemplatesController
  class TemplatesController < ::ApplicationController
    include ::DataTablesAdapter

    protect_from_forgery except: [:new], with: :exception
    layout 'application'

    before_action :sanatize_template_body, only: [:create, :update]
    before_action :sanatize_instance_preview_params, only: [:instant_preview]

    def index
      @notice_kinds = Templates::TemplateModel.all
      @datatable = Effective::Datatables::NoticesDatatable.new
      @tab = params[:tab] || 'templates'
      @errors = []
    end

    def show
      return unless params['id'] == 'upload_notices'

      redirect_to action: :index
    end

    def new
      @template = Templates::TemplateModel.new
      @inserts = Templates::TemplateModel.where(doc_type: :insert)

      respond_to do |format|
        format.html
        format.js
      end
    end

    def edit
      @template = Templates::TemplateModel.find(params[:id])
      @template.body = Bodies::BodyModel.new unless @template.body
      @inserts = Templates::TemplateModel.where(doc_type: :insert)
      render layout: 'application'
    end

    def create
      result = Templates::TemplateContract.new.call(template_params.to_h)
      if result.success?
        record = Templates::Template.new(result.to_h).create_model

        if record.success?
          flash[:notice] = 'Notice created successfully'
          redirect_to action: :edit, id: record.success.id
        else
          @errors = Array.wrap(record.failure)
          flash[:error] = "Unable to create template due to #{@errors}"
          redirect_to action: :index
        end
      else
        flash[:error] = "Unable to create template due to #{result.errors}"
        render action: 'index'
      end
    end

    def update
      result = Templates::TemplateContract.new.call(template_params.to_h)

      if result.success?
        record = Templates::Template.new(result.to_h).update_model(params['id'])
        if record.success?
          flash[:notice] = 'Notice content updated successfully'
        else
          @errors = Array.wrap(record.failure)
          flash[:error] = "Unable to create template due to #{@errors}"
        end
        redirect_to action: :index
      else
        flash[:error] = "Unable to update template due to #{result.errors}"
        render action: 'index'
      end
    end

    def instant_preview
      template =
        Templates::TemplateModel.instant_preview_for(instant_preview_params)

      if template.success?
        @rendered_template = template.success[:rendered_template]
      else
        errors = template.failure
        errors = template.failure.errors if template.failure.respond_to?(
          :errors
        )
        @errors = Array.wrap(errors).flatten
      end
    end

    def preview
      template = Templates::TemplateModel.find(params['id'])
      documents_operation =
        Documents::CreateWithInsert.new.call(
          { template_model: template, preview: 'true', cover_page: true }
        )

      if documents_operation.success?
        send_file documents_operation.success[:document].path,
                  type: documents_operation.success[:template][:content_type],
                  disposition: 'inline'
      else
        flash[:error] = 'Failed to load preview.'
        @notice_kinds = Templates::TemplateModel.all
        @datatable = Effective::Datatables::NoticesDatatable.new
        redirect_back(
          fallback_location: root_path,
          flash: {
            error: documents_operation.failure
          }
        )
      end
    end

    def destroy
      Templates::TemplateModel.where(id: params['id']).first.delete
      flash[:notice] = 'Notices deleted successfully'
      redirect_to action: :index
    end

    def download_notices
      templates =
        Templates::TemplateModel.where(:id.in => params['ids'].split(','))

      send_data templates.to_csv,
                filename: "notices_#{Date.today.strftime('%m_%d_%Y')}.csv",
                disposition: 'attachment',
                type: 'text/csv'
    end

    def upload_notices
      @errors = []
      if file_content_type == 'text/csv'
        templates = Roo::Spreadsheet.open(params[:file].tempfile.path)
        templates.each do |template_row|
          next if template_row[1] == 'Notice Number'

          if Templates::TemplateModel.where(subject: template_row[1]).blank?
            template = Templates::TemplateModel.build_notice_kind(template_row)
            unless template.save
              @errors <<
                "Notice #{template_row[1]} got errors: #{template.errors}"
            end
          else
            @errors << "Notice #{template_row[1]} already exists."
          end
        end
      else
        @errors << 'Please upload csv format files only.'
      end

      flash[:notice] = 'Notices loaded successfully.' if @errors.empty?
      @notice_kinds = Templates::TemplateModel.all
      @datatable = Effective::Datatables::NoticesDatatable.new

      render action: 'index'
    end

    def fetch_tokens
      service = Services::NoticeKindService.new(params['market_kind'])
      service.builder = builder_param
      respond_to do |format|
        format.html
        format.json { render json: { tokens: service.editor_tokens } }
      end
    end

    def fetch_placeholders
      service = Services::NoticeKindService.new(params['market_kind'])
      service.builder = builder_param
      respond_to do |format|
        format.html
        format.json do
          render json: {
            sections: service.sections,
            placeholders: service.placeholders,
            setting_placeholders: service.setting_placeholders
          }
        end
      end
    end

    def fetch_recipients
      recipients =
        Services::NoticeKindService.new(params['market_kind']).recipients

      respond_to do |format|
        format.html
        format.json { render json: { recipients: recipients } }
      end
    end

    private

    def instant_preview_params
      params.permit(:body, :subject, :key, :title, :marketplace, :recipient)
    end

    def file_content_type
      params[:file]&.content_type
    end

    def check_hbx_staff_role
      return unless current_user.blank? || !current_user.has_hbx_staff_role?

      redirect_to main_app.root_path,
                  flash: {
                    error: 'You must be an HBX staff member'
                  }
    end

    def template_params
      params
        .require(:template)
        .permit(*::Templates::TemplateContract.params.key_map.dump)
    end

    def entities_contracts_mapping
      {
        'AcaEntities::People::ConsumerRole' =>
          'AcaEntities::Contracts::People::ConsumerRoleContract',
        '::AcaEntities::Families::Family' =>
          '::AcaEntities::Contracts::Families::FamilyContract',
        '::AcaEntities::MagiMedicaid::Application' =>
          '::AcaEntities::MagiMedicaid::Contracts::ApplicationContract'
      }
    end

    def builder_param
      entities_contracts_mapping[params['builder']] ||
        '::AcaEntities::MagiMedicaid::Contracts::ApplicationContract'
    end

    def sanatize_instance_preview_params
      template = instant_preview_params
      raw_text = [template['title'], template['subject'], template['body']].join('\n\n')
      validate_params(raw_text)
    end

    def sanatize_template_body
      template = template_params
      raw_text = [template['title'], template['description'], template['body']].join('\n\n')
      validate_params(raw_text)
    end

    def validate_params(raw_text)
      result = Templates::TemplateModel::BLOCKED_ELEMENTS.any? {|str| raw_text.include?(str)}
      return unless result
      flash[:error] = "Template contains unauthorized content"
      redirect_to main_app.root_path
    end
  end
end
