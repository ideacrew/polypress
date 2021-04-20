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
    serialized_pdf = yield generate_pdf(params)

    Success(serialized_pdf)
  end

  private

  def document_path(template)
    document_title = template.title.titleize.gsub(/\s+/, '_')

    Rails.root.join("tmp", "#{document_title}.pdf")
  end

  def generate_pdf(params)
    document = File.open(document_path(params[:template]), 'wb') do |file|
      file << WickedPdf.new.pdf_from_string(params[:rendered_template])
    end

    if document
      Success([document, params[:template]])
    else
      Failure("Unable to generate PDF document")
    end
  end
end