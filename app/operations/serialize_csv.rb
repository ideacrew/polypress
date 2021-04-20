# frozen_string_literal: true

# Transform payload into CSV
class SerializeCsv
  send(:include, Dry::Monads[:result, :do])

  # @param [rendered_template] :rendered_template Rendered Liquid Template
  # @param [template] :template Template Object
  # @param [options] Additional options for serializer
  # @param [Dry::Struct] AcaEntities::Entity to proccess
  # @return [Dry:Monad] passed params into csv
  def call(params)
    csv = yield generate_csv(params)
    Success(csv)
  end

  private

  def document_path(template)
    document_title = template.title.titleize.gsub(/\s+/, '_')

    Rails.root.join("tmp", "#{document_title}.csv")
  end

  def generate_csv(params)
    CSV.open(document_path(params[:template], 'csv'), 'w', force_quotes: true) do |csv|
      params[:rendered_template].scan(%r{<p[^>]*>(.+?)</p>}).each do |line|
        csv << line[0].split(',')
      end
    end

    Success(true)
  end
end