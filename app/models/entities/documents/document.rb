# frozen_string_literal: true

# require_relative 'operations/documents/create'

module Documents

  HTML_FORMATTER = lambda do |context|
  end

  PDF_FORMATTER = lambda do |context|
  end

  EDI_834_FORMATTER = {}.freeze

  JSON_FORMATTER = lambda do |context|
  end

  TEXT_FORMATTER = lambda do |context|
    puts("*** #{context.title} ***")
    context.text.each { |line| puts "#{line}\n" }
  end

  XML_FORMATTER = lambda do |context|
  end

  class Document < Dry::Struct

    attribute :document, Types::String

  end

end