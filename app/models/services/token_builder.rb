# frozen_string_literal: true

# rubocop:disable Style/HashEachMethods
module Services
  # Responsible to build tokens required for notice generation
  module TokenBuilder

    # def placeholders
    #   placeholders = []

    #   prepend_namespace = model_builder.class_name.gsub('Contract', '')
    #   model_builder.schema.key_map.each do |schema_key|
    #     next unless schema_key.is_a?(Dry::Schema::Key::Array)

    #     placeholders << {
    #       title: "Loop: #{schema_key.name.camelcase}",
    #       target: [prepend_namespace.underscore, schema_key.name].join('.'),
    #       iterator: schema_key.name.singularize,
    #       type: 'loop'
    #     }
    #     schema_key.member.keys.each do |key|
    #       placeholders << {
    #         title: "&nbsp;&nbsp; #{key.name.humanize}",
    #         target: [schema_key.name.singularize, key.name].join('.')
    #       }
    #     end
    #   end

    #   conditions.each do |condition|
    #     placeholders << {
    #       title: "Condition: #{condition.humanize}",
    #       target: [prepend_namespace, condition].join('.'),
    #       type: 'condition'
    #     }
    #   end

    #   placeholders
    # end

    def placeholders
      placeholders = []

      [:if, :iterator, :tablerow, :comment].each do |type|
        placeholders << {
          title: type.to_s.titleize,
          type: type
        }
      end

      placeholders
    end

    def editor_tokens
      prepend_namespace = [model_builder.to_s.split('::').last.gsub('Contract', '')]
      model_builder.schema.key_map.each_with_object([]) do |schema_key, attributes|
        tokens(prepend_namespace, schema_key, attributes)
      end.sort
    end

    def tokens(prepend_namespace, schema_key, attributes)
      case schema_key
      when Dry::Schema::Key::Hash
        namespace = prepend_namespace + [schema_key.name.camelcase]
        schema_key.members.keys.each do |key|
          tokens(namespace, key, attributes)
        end
      when Dry::Schema::Key::Array
        namespace = [schema_key.name.singularize.camelcase]
        schema_key.member.keys.each do |key|
          tokens(namespace, key, attributes)
        end
      when Dry::Schema::Key
        attributes << [
          "#{prepend_namespace.join(' ')} - #{schema_key.name.camelcase}",
          [prepend_namespace.map(&:underscore).join('.').gsub('&nbsp;&nbsp;.', ''), schema_key.to_dot_notation].join('.')
        ]
      end
    end

    # def tokens(prepend_namespace, schema_key, attributes)
    #   case schema_key
    #   when Dry::Schema::Key::Hash
    #     namespace = prepend_namespace + [schema_key.name.camelcase]
    #     schema_key.members.keys.each do |key|
    #       tokens(namespace, key, attributes)
    #     end
    #   when Dry::Schema::Key::Array
    #   # do nothing for collections
    #   when Dry::Schema::Key
    #     attributes << ["#{prepend_namespace.join(' ')} - #{schema_key.name.camelcase}",
    #                    [prepend_namespace.map(&:underscore).join('.'), schema_key.to_dot_notation].join('.')]
    #   end
    # end

    def conditions
      []
    end
  end
end
# rubocop:enable Style/HashEachMethods