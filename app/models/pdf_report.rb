# frozen_string_literal: true

# Main class to append data on to 1095A tax forms
class PdfReport < Prawn::Document
  include Prawn::Measurements

  def initialize(options = {})
    options.merge!(:margin => [50, 70]) if options[:margin].nil?

    super(options)

    font "Times-Roman"
    font_size 12
  end

  def print_date
    text Time.now.strftime("%m/%d/%Y")
  end

  def footer
  end

  def text(text, options = {})
    options.merge!({ :align => :justify }) unless options.key?(:align)

    super text, options
  end

  def subheading(sub_heading)
    move_down 20
    text sub_heading, { :style => :bold, :size => 14, :color => "0a558e" }
    move_down 15
  end

  def list_display(data)
    data.each do |item|
      float do
        bounding_box [10, cursor], :width => 10 do
          # text "\u2022"
        end
      end

      bounding_box [0, cursor], :width => 500 do
        text item
      end

      move_down(5)
    end
  end

  def cents_to_dollars(cents)
    number_to_currency(cents / 100.0)
  end

end
