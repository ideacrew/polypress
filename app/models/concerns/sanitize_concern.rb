# frozen_string_literal: true

# The SanitizeConcern module provides a method for sanitizing input values.
# It is intended to be used as a mixin to add sanitization functionality to any class.
module SanitizeConcern
  extend ActiveSupport::Concern

  included do
    # Sanitized a string into a still-styled format for PDF creation
    # It uses the lists of HTML5 tags from Loofa and adds the 'style' tag to the list of acceptable tags.
    # For attributes, it used the list of acceptable attributes from Loofah.
    #
    # @param pdf_string [Object] The value to sanitize.
    # @return [Object] The sanitized value if it was a string, or the original value if it was not a string.
    def sanitize_pdf(pdf_string)
      return pdf_string unless pdf_string.is_a?(String)

      ActionController::Base.helpers.sanitize(
        pdf_string,
        tags: Loofah::HTML5::SafeList::ACCEPTABLE_ELEMENTS.dup.delete("select").add('style', 'title'),
        attributes: Loofah::HTML5::SafeList::ACCEPTABLE_ATTRIBUTES
      )
    end
  end
end
