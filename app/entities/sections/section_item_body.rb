# frozen_string_literal: true

module Sections
  # Markup content associated with a {Sections::Section}
  class SectionItemBody < Dry::Struct
    # References to key/value pairs in the {% schema %} tag
    # Can use these to correlate with HML elements, e.g. , id, type, label, etc.
    # @example
    # {{ section.settings.custom_text_title }}
    # {% schema %}
    # {
    #   "name": "Text Box",
    #   "settings": [
    #     {
    #       "id": "custom_text_title",
    #       "type": "text",
    #       "label": "Text box heading",
    #       "default": "Title"
    #     }
    #   ]
    # }
    # {% endschema %}
    attribute :content_type, Types::String
    attribute :markup, Types::String
    # attribute :schema, Schema
    # attribute :settings, Types::Array.of(Schemas::Setting)

    # schema = {
    #   name: '',
    #   type: 'link_list',
    #   settings: [
    #     {
    #       type: 'text',
    #       id: 'heaading',
    #       default: 'Quick Links',
    #       label: 't:sections.footer.blocks.link_list.settings.heading.label',
    #       info: 't:sections.footer.blocks.link_list.settings.heading.info'
    #     },
    #     {
    #       type: 'link_list',
    #       id: 'menu',
    #       default: 'footer',
    #       label: 't:sections.footer.blocks.link_list.settings.menu.label',
    #       info: 't:sections.footer.blocks.link_list.settings.menu.info'
    #     }
    #   ]
    # }
  end
end
