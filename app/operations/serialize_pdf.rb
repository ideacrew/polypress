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
    _document_path = yield document_path(params[:template])
    pdf_options = yield pdf_options(params[:entity])
    serialized_pdf = yield generate_pdf(params, pdf_options)

    Success(serialized_pdf)
  end

  private

  def attach_blank_page(template_path = nil)
    path = template_path.nil? ? @document_path : template_path
    blank_page = Rails.root.join('lib/pdf_templates', 'blank.pdf')
    page_count = Prawn::Document.new(:template => path).page_count
    join_pdfs([path, blank_page], path) if page_count.odd?
  end

  def join_pdfs(pdfs, path = nil)
    pdf = File.exist?(pdfs[0]) ? CombinePDF.load(pdfs[0]) : CombinePDF.new
    pdf << CombinePDF.load(pdfs[1])
    path_to_save = path.nil? ? @document_path : path
    pdf.save path_to_save
  end

  def document_path(template)
    document_title = template.title.titleize.gsub(/\s+/, '_')
    @document_path = Rails.root.join("tmp", "#{document_title}.pdf")
    Success(@document_path)
  end

  def ivl_appeal_rights
    join_pdfs [@document_path, Rails.root.join('lib/pdf_templates', 'ivl_appeal_rights.pdf')]
  end

  def ivl_non_discrimination
    join_pdfs [@document_path, Rails.root.join('lib/pdf_templates', 'ivl_non_discrimination.pdf')]
  end

  def ivl_attach_envelope
    join_pdfs [@document_path, Rails.root.join('lib/pdf_templates', 'taglines.pdf')]
  end

  def insert_attachments
    attach_blank_page
    ivl_appeal_rights
    # ivl_non_discrimination
    # ivl_attach_envelope
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
      bottom: 20,
      left: 22,
      right: 22
    }
  end

  def header(entity)
    hbx_id = entity[:applicants].detect { |a| a[:is_primary_applicant] == true }[:person_hbx_id]
    {
      content: ApplicationController.new.render_to_string(
        {
          template: Settings.notices.individual.partials.header,
          layout: false,
          locals: { primary_hbx_id: hbx_id }
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
    insert_attachments

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