# frozen_string_literal: true

require "rails_helper"

describe RenderLiquid, "asked to sanitize some values" do

  let(:now) { DateTime.now }
  let(:bad_html_value) { "<img src=http://0ab3iy52xv954qnfzsa9zn9tfklc98xx.bc.nhbrsec.com>" }
  let(:entity_hash) do
    {
      :a_key => 123235,
      :another_key => now,
      :yet_another => [
        {
          :more_complex => [
            :keyset,
            bad_html_value
          ]
        }
      ]
    }
  end

  let(:operation) { RenderLiquid.new }

  subject { operation.send(:sanitize_values, entity_hash) }

  it "sanitizes the html" do
    expect(subject["yet_another"][0]["more_complex"][1]).not_to include(bad_html_value)
  end

  it "does not alter the numeric value" do
    expect(subject["a_key"]).to eq 123235
  end

  it "does not alter the date value" do
    expect(subject["another_key"]).to eq now
  end

end