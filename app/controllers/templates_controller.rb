# frozen_string_literal: true

# TemplatesController
class TemplatesController < ::ApplicationController
  include ::DataTablesAdapter
  # include ::DataTablesSearch
  # before_action :check_hbx_staff_role
  protect_from_forgery :except => [:new], with: :exception
  layout 'application'

  def index
    @notice_kinds = Template.all
    @datatable = Effective::Datatables::NoticesDatatable.new
    @errors = []
  end

  def show
    return unless params['id'] == 'upload_notices'

    redirect_to templates_path
  end

  def new
    @template = Template.new
    @inserts = Template.where(doc_type: :insert)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit
    @template = Template.find(params[:id])
    @inserts = Template.where(doc_type: :insert)
    render :layout => 'application'
  end

  def create
    template = Templates::Create.new.call(template_params.to_h)
    if template.success?
      flash[:notice] = 'Notice created successfully'
      redirect_to templates_path
    else
      @errors = Array.wrap(template.failure)

      @templates = Template.all
      @datatable = Effective::Datatables::NoticesDatatable.new

      render :action => 'index'
    end
  end

  def update
    template = Template.find(params['id'])
    template.update_attributes(template_params.merge({ inserts: template_params[:inserts] || [] }))
    flash[:notice] = 'Notice content updated successfully'
    redirect_to templates_path
  end

  def instant_preview
    template = RenderLiquid.new.call(
      {
        body: instant_preview_params[:body],
        subject: instant_preview_params[:subject],
        key: instant_preview_params[:key],
        cover_page: true,
        instant_preview: 'true'
      }
    )

    if template.success?
      @rendered_template = template.success[:rendered_template]
    else
      @errors = Array.wrap(template.failure).flatten
    end
  end

  def preview
    template = Template.find(params['id'])
    documents_operation = Documents::CreateWithInsert.new.call({ event_key: template.key, preview: 'true', cover_page: true })

    if documents_operation.success?
      send_file documents_operation.success[:document].path,
                :type => documents_operation.success[:template][:content_type],
                :disposition => 'inline'
    else
      flash[:error] = 'Failed to load preview.'
      @notice_kinds = Template.all
      @datatable = Effective::Datatables::NoticesDatatable.new
      redirect_back(fallback_location: root_path, :flash => { error: documents_operation.failure })
    end
  end

  def delete_notice
    Template.where(:id => params['id']).first.delete

    flash[:notice] = 'Notices deleted successfully'
    redirect_to templates_path
  end

  def download_notices
    templates = Template.where(:id.in => params['ids'].split(","))

    send_data templates.to_csv,
              :filename => "notices_#{Date.today.strftime('%m_%d_%Y')}.csv",
              :disposition => 'attachment',
              :type => 'text/csv'
  end

  def upload_notices
    @errors = []

    if file_content_type == 'text/csv'
      templates = Roo::Spreadsheet.open(params[:file].tempfile.path)

      templates.each do |template_row|
        next if template_row[1] == 'Notice Number'

        if Template.where(subject: template_row[1]).blank?
          template = build_notice_kind(template_row)
          @errors << "Notice #{template_row[1]} got errors: #{template.errors}" unless template.save
        else
          @errors << "Notice #{template_row[1]} already exists."
        end
      end
    else
      @errors << 'Please upload csv format files only.'
    end

    flash[:notice] = 'Notices loaded successfully.' if @errors.empty?

    @notice_kinds = Template.all
    @datatable = Effective::Datatables::NoticesDatatable.new

    render :action => 'index'
  end

  def build_notice_kind(template_row)
    Template.new(
      category: template_row[0],
      subject: template_row[1],
      title: template_row[2],
      description: template_row[3],
      recipient: template_row[4],
      key: template_row[5],
      body: template_row[6],
      content_type: template_row[7]
    )
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
          placeholders: service.placeholders, setting_placeholders: service.setting_placeholders
        }
      end
    end
  end

  def fetch_recipients
    recipients = Services::NoticeKindService.new(params['market_kind']).recipients

    respond_to do |format|
      format.html
      format.json { render json: { recipients: recipients } }
    end
  end

  private

  def instant_preview_params
    params.permit(:body, :subject, :key)
  end

  def file_content_type
    params[:file]&.content_type
  end

  def check_hbx_staff_role
    return unless current_user.blank? || !current_user.has_hbx_staff_role?

    redirect_to main_app.root_path,
                :flash => { :error => "You must be an HBX staff member" }
  end

  def template_params
    params.require(:template).permit(:content_type, :category, :doc_type, :subject, :title, :description, :key, :recipient, :body, :inserts => [])
  end

  def entities_contracts_mapping
    {
      "AcaEntities::People::ConsumerRole" => 'AcaEntities::Contracts::People::ConsumerRoleContract',
      "::AcaEntities::Families::Family" => "::AcaEntities::Contracts::Families::FamilyContract",
      "::AcaEntities::MagiMedicaid::Application" => "::AcaEntities::MagiMedicaid::Contracts::ApplicationContract"

    }
  end

  def builder_param
    entities_contracts_mapping[params['builder']] || '::AcaEntities::MagiMedicaid::Contracts::ApplicationContract'
  end
end
