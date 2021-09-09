# frozen_string_literal: true

# Find and cache the markdown of a section_item component
class PartialCache
  def self.load(template_name, context:, parse_context:)
    cached_partials = (context.registers[:cached_partials] ||= {})
    cached = cached_partials[template_name]
    return cached if cached

    result = Sections::FindSectionItem.call(section_item_key: template_name)
    if result.success?
      source = result.value!
    else
      "Error #{result.failure} finding section: #{template_name}"
    end

    # file_system =
    #   (context.registers[:file_system] ||= Liquid::Template.file_system)
    # source = file_system.read_template_file(template_name)

    parse_context.partial = true

    template_factory =
      (context.registers[:template_factory] ||= Liquid::TemplateFactory.new)
    template = template_factory.for(template_name)

    partial = template.parse(source, parse_context)
    cached_partials[template_name] = partial
  ensure
    parse_context.partial = false
  end
end
