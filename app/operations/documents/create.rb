# frozen_string_literal: true

module Documents
  # Transform payload into a Document
  class Create
    send(:include, Dry::Monads[:result, :do])

    # @param [options] Additional options for serializer
    # @param [Dry::Struct] AcaEntities::Entity to proccess
    # @return [Dry:Monad] passed params into pdf
    def call(params)
      template           = yield fetch_template(params)
      # prepend
      rendered_template  = yield render_liquid_template(template, params)
      # append
      output             = yield create_document(template, rendered_template, params)
      Success(output)
    end

    private

    def fetch_template(params)
      template = Template.where(id: params[:id]).first

      if template
        Success(template)
      else
        Failure("Unable to find template with #{params[:id]}")
      end
    end

    def resource(_params)
      {
        'site' => { 'home_url' => 'www.homeurl.com' },
        'applicant_reference' => { 'email_address' => 'email@address.com' }
      }
    end

    def stubbed_object
      {
        'site' => { 'home_url' => 'www.homeurl.com' },
        'applicant_reference' => { 'email_address' => 'email@address.com' },
        'user' => { 'kind' => 'USER KIND', 'relative_reference' => { 'email_address' => 'test@test.com' } }
      }
    end

    def render_liquid_template(template, params)
      payload = params[:preview] ? stubbed_object : resource(params)
      RenderLiquid.new.call({ body: template.body, entity: payload })
    end

    def create_document(template, rendered_template, params)
      doc_params = params.merge({ rendered_template: rendered_template, template: template })

      case template.content_type
      when 'application/pdf'
        SerializePdf.new.call(doc_params)
      when 'text/csv'
        SerializeCsv.new.call(doc_params)
      when 'text/plain'
        SerializeText.new.call(doc_params)
      else
        Failure('Unknown format specified for document creation')
      end
    end
  end
end