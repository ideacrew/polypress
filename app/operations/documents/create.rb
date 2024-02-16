# frozen_string_literal: true

module Documents
  # Transform payload into a Document
  class Create
    send(:include, Dry::Monads[:result, :do, :try])
    include ::SanitizeConcern

    # @param [options] Additional options for serializer
    # @param [Dry::Struct] AcaEntities::Entity to proccess
    # @return [Dry:Monad] passed params into pdf
    def call(params)
      template_entity = yield fetch_template(params)
      rendered_template = yield render_liquid_template(template_entity, params)
      sanitized_template =
        yield sanitize_template(rendered_template[:rendered_template])
      output =
        yield create_document(
          template_entity,
          rendered_template,
          params,
          sanitized_template
        )
      Success(output)
    end

    private

    def fetch_template(params)
      record = params[:template_model]
      if record
        result = Templates::TemplateContract.new.call(record.to_entity)
        if result.success?
          template = Templates::Template.new(result.to_h)
          Success(template)
        else
          Failure(result)
        end
      else
        Failure('Missing template model')
      end
    end

    def render_liquid_template(template, params)
      RenderLiquid.new.call(
        body: template.body,
        template: template,
        subject: template.print_code,
        key: params[:key],
        cover_page: params[:cover_page],
        entity: params[:entity],
        preview: params[:preview]
      )
    end

    def sanitize_template(template)
      Try() { sanitize_pdf(template) }.to_result
    end

    def create_document(template, rendered_template, params, sanitized_template)
      doc_params =
        params.merge(
          {
            rendered_template: sanitized_template,
            template: template,
            entity: rendered_template[:entity]
          }
        )
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
