# frozen_string_literal: true

# Transform payload into PDF
class SerializePdf
  send(:include, Dry::Monads[:result, :do])

  # @param [rendered_template] :rendered_template Rendered Liquid Template
  # @param [template] :template Template Object
  # @param [options] Additional options for serializer
  # @param [Dry::Struct] AcaEntities::Entity to proccess
  # @return [Dry:Monad] passed params into pdf
  def call(params)
    _document_path = yield document_path(params)
    pdf_options = yield pdf_options(params[:entity])
    serialized_pdf = yield generate_pdf(params, pdf_options)

    Success(serialized_pdf)
  end

  private

  def document_path(params)
    template = params[:template]
    entity = params[:entity]
    document_title = template.title.titleize.gsub(/[^0-9A-Za-z]/, '')
    hbx_id = recipient_hbx_id(entity)
    @document_path = Rails.root.join("tmp", "#{hbx_id}_#{document_title}_#{template.print_code}_IVL_#{DateTime.now.strftime("%Y%m%d%H%M%S")}.pdf")
    Success(@document_path)
  end

  def pdf_options(entity)
    options = {
      margin: set_margin,
      disable_smart_shrinking: true,
      dpi: 96,
      page_size: 'Letter',
      formats: :html,
      encoding: 'utf8',
      header: header(entity),
      footer: footer
    }

    Success(options)
  end

  def set_margin
    {
      top: 10,
      bottom: 24,
      left: 22,
      right: 22
    }
  end

  def recipient_hbx_id(entity)
    members = entity[:applicants] || entity[:family_members]
    members.detect { |a| a[:is_primary_applicant] == true }[:person_hbx_id]
  end

  def header(entity)
    {
      content: ApplicationController.new.render_to_string(
        {
          template: Settings.notices.individual.partials.header,
          layout: false,
          locals: { primary_hbx_id: recipient_hbx_id(entity) }
        }
      )
    }
  end

  def footer
    {
      content: ApplicationController.new.render_to_string(
        {
          template: Settings.notices.individual.partials.footer,
          layout: false
        }
      )
    }
  end

  def generate_pdf(params, pdf_options)
    document = File.open(@document_path, 'wb') do |file|
      file << WickedPdf.new.pdf_from_string(params[:rendered_template], pdf_options)
    end

    if document
      Success(
        {
          document: document,
          template: params[:template].attributes
        }
      )
    else
      Failure("Unable to generate PDF document")
    end
  end
end