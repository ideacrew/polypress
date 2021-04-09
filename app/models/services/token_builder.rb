module Services
  module TokenBuilder

    def placeholders
      placeholders = []
  
      prepend_namespace = model_builder.class_name.gsub('Contract', '')
      model_builder.schema.key_map.each do |schema_key|
        next unless schema_key.is_a?(Dry::Schema::Key::Array)
  
        placeholders << {
          title: "Loop: #{schema_key.name.camelcase}",
          target: [prepend_namespace.underscore, schema_key.name].join('.'),
          iterator: schema_key.name.singularize,
          type: 'loop'
        }
        schema_key.member.keys.each do |key|
          placeholders << {
            title: "&nbsp;&nbsp; #{key.name.humanize}",
            target: [schema_key.name.singularize, key.name].join('.'),
          }
        end
      end
  
      conditions.each do |condition|
        placeholders << {
          title: "Condition: #{condition.humanize}",
          target: [prepend_namespace, condition].join('.'),
          type: 'condition'
        }
      end
  
      placeholders
    end

    def editor_tokens
      prepend_namespace = [model_builder.class_name.gsub('Contract', '')]
      model_builder.schema.key_map.inject([]) do |attributes, schema_key|
        tokens(prepend_namespace, schema_key, attributes)
        attributes
      end
    end
  
    def tokens(prepend_namespace, schema_key, attributes)
      if schema_key.is_a?(Dry::Schema::Key::Hash)
        namespace = prepend_namespace + [schema_key.name.camelcase]
        schema_key.members.keys.each do |key|
          tokens(namespace, key, attributes)
        end
      elsif schema_key.is_a?(Dry::Schema::Key::Array)
      # do nothing for collections
      elsif schema_key.is_a?(Dry::Schema::Key)
        attributes << ["#{prepend_namespace.join(' ')} - #{schema_key.name.camelcase}", [prepend_namespace.map { |o| o.underscore }.join('.'), schema_key.to_dot_notation].join('.')]
      end
    end

    def conditions
      []
    end
  end
end

keywords = {'if' => '', 'else' => '', 'end' => '', 'elsif' => '', 'unless' => ''}

class Conditional < Placeholder
  attribute :title
  attribute :target
end

class Enumerator < Placeholder
  attribute :iterator
  attribute :title
  attribute :target
end

class Attribute < Placeholder
  attribute :title
  attribute :target
end

class Filter < Placeholder
end

class Placeholder
  attribute :anchor_position
  attribute :label

  def method_name
    
  end
end


anchor_position:
type: [condition, ]