# frozen_string_literal: true

require 'rails_helper'

## This class intended to replace following code ##
##
# def determine_eligibilities(application_entity, event_key)
#   return Success([event_key]) unless event_key.to_s == 'determined_mixed_determination'

#   peds = application_entity.tax_households.flat_map(&:tax_household_members).map(&:product_eligibility_determination)
#   event_names =
#     peds.inject([]) do |e_names, ped|
#       e_name =
#         if ped.is_ia_eligible
#           'determined_aptc_eligible'
#         elsif ped.is_medicaid_chip_eligible || ped.is_magi_medicaid
#           'determined_magi_medicaid_eligible'
#         elsif ped.is_totally_ineligible
#           'determined_totally_ineligible'
#         elsif ped.is_uqhp_eligible
#           'determined_uqhp_eligible'
#         end

#       e_names << e_name
#     end
#   Success(event_names.uniq.compact)
# end

RSpec.describe EventRoutes::EventRouteContract do
  subject { described_class.new }

  let(:event_name) { 'determined_aptc_eligible' }
  let(:event_attributes) do
    {
      application: {
        applicants: [
          { hbx_id: '12345', is_primary: true },
          { hbx_id: '54321', is_primary: false }
        ]
      }
    }
  end
  let(:filter_criteria) do
    'application_entity.tax_households.flat_map(&:tax_household_members).map(&:product_eligibility_determination).is_ia_eligible'
  end

  let(:required_params) { { event_name: event_name } }
  let(:optional_params) do
    { attributes: attributes, filter_criteria: filter_criteria }
  end
  let(:all_params) { required_params.deep_merge(optional_params) }

  context 'Given gapped or invalid parameters' do
    context 'and parameters are empty' do
      it { expect(subject.call({}).success?).to be_falsey }
      it 'should fail validation' do
        expect(subject.call({}).error?(required_params.keys.first)).to be_truthy
      end
    end
  end

  context 'Given valid parameters' do
    context 'and required parameters only' do
      it 'should pass validation' do
        result = subject.call(required_params)

        expect(result.success?).to be_truthy
        expect(result.to_h).to eq required_params
      end
    end

    context 'and required and optional parameters' do
      it 'should pass validation' do
        result = subject.call(all_params)

        expect(result.success?).to be_truthy
        expect(result.to_h).to eq all_params
      end
    end
  end
end
