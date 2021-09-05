# frozen_string_literal: true

HTML_FORMATTER = lambda { |context| }

PDF_FORMATTER = lambda { |context| }

EDI_834_FORMATTER = {}.freeze

JSON_FORMATTER = lambda { |context| }

TEXT_FORMATTER =
  lambda do |context|
    puts("*** #{context.title} ***")
    context.text.each { |line| puts "#{line}\n" }
  end

XML_FORMATTER = lambda { |context| }

module Documents
  # An instance of a parsed template
  class Document < Dry::Struct
    attribute :key, Types::String
    attribute :title, Types::String
    attribute :description, Types::String

    attribute :sections do |section|
      Types::Array.of(Section)
    end
    attribute :order, Types::Array.of(Types::Symbol)

    attribute :category, Types::String
    attribute :author, Types::String
    attribute :tags, Types::Array.of(Types::String)
    attribute :created_at, Types::DateTime
    attribute :updated_at, Types::DateTime
    attribute :published_at, Types::DateTime
  end
end
