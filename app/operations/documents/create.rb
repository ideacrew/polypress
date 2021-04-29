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

    def render_liquid_template(template, params)
      RenderLiquid.new.call({ body: template.body, entity: params[:entity], preview: params[:preview] })
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