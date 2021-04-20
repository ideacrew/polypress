# frozen_string_literal: true

# Transform payload into plain text
class SerializeText
  send(:include, Dry::Monads[:result, :do])

  # @param [rendered_template] :rendered_template Rendered Liquid Template
  # @param [template] :template Template Object
  # @param [options] Additional options for serializer
  # @param [Dry::Struct] AcaEntities::Entity to proccess
  # @return [Dry:Monad] passed params into text
  def call(params)
    pdf = yield generate_plain_text(params)
    Success(pdf)
  end

  private

  def document_path(template)
    document_title = template.title.titleize.gsub(/\s+/, '_')

    Rails.root.join("tmp", "#{document_title}.txt")
  end

  def generate_plain_text(params)
    File.open(document_path(params[:template]), 'wb') do |file|
      file << Nokogiri::HTML(params[:rendered_template]).text
    end

    Success(true)
  end
end