# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/template_params'

RSpec.describe Templates::Find, dbclean: :after_each do
  subject { described_class.new }
  include_context 'template_params'

  context 'with some records added to the database', dbclean: :after_each do
    let!(:individual_market_recs) do
      3.times do |index|
        Templates::Template.new(all_params.merge(key: index.to_s, subscriber: { event_name: "enroll_app.customer_created_#{index}" })).create_model
      end
    end

    let!(:shop_market_recs) do
      2.times do |index|
        Templates::Template.new(
          all_params.merge({ key: (index + 10).to_s, marketplace: 'aca_shop',
                             subscriber: { event_name: "enroll_app.customer_created_#{index + 10}" } })
        ).create_model
      end
    end

    context 'the find operation should return records matching criteria' do
      context '#find by_key' do
        it 'should find the correct record' do
          result = subject.call(scope_name: :by_key, options: { value: '0' })

          expect(result.success?).to be_truthy
          expect(result.success.size).to eq 1
        end
      end

      context '#find_by aca_individual marketplace' do
        it 'should find the correct individual market records' do
          result = subject.call(scope_name: :aca_individual_market)

          expect(result.success?).to be_truthy
          expect(result.success.size).to eq 3
        end
      end

      context '#find_by aca_shop marketplace' do
        it 'should find the correct shop market records' do
          result = subject.call(scope_name: :aca_shop_market)

          expect(result.success?).to be_truthy
          expect(result.success.size).to eq 2
        end
      end

      context '#find all' do
        it 'should find all records' do
          result = subject.call(scope_name: :all)

          expect(result.success?).to be_truthy
          expect(result.success.size).to eq 5
        end
      end
    end
  end
end
