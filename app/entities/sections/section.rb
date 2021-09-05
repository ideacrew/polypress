# frozen_string_literal: true

module Sections
  class Section
    attribute :key, Types::String
    attribute :title, Types::String
    attribute :description, Types::String
    attribute :type, Types::String

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
    attribute :settings, Types::Hash

    attribute :blocks, Types::Array.of(Block)
    attribute :block_order, Types::Array.of(Types::String)

    # Limits a section to only appear on certain page types
    attribute :templates, Types::Array.of(Types::String)

    schema = {
      name: '',
      type: 'link_list',
      settings: [
        {
          type: 'text',
          id: 'heaading',
          default: 'Quick Links',
          label: 't:sections.footer.blocks.link_list.settings.heading.label',
          info: 't:sections.footer.blocks.link_list.settings.heading.info'
        },
        {
          type: 'link_list',
          id: 'menu',
          default: 'footer',
          label: 't:sections.footer.blocks.link_list.settings.menu.label',
          info: 't:sections.footer.blocks.link_list.settings.menu.info'
        }
      ]
    }
    # settings
    #   type
    #   label
    #   id
    #   info
    #   content
    #   default
    #   options
    #     []
    # default: {
    #   blocks: []
    #   }
  end
end
