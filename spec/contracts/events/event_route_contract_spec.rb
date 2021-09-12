# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Events::EventRouteContract do
  subject { described_class.new }

  let(:event_name) { 'enrollment_eigibility_determined' }
  let(:template_key) { 'uqhp_welcome_notice' }
  let(:event_route_item) do
    { event_name.to_s => { template_key: template_key } }
  end
  let(:required_params) { { event_routes: event_route_item } }

  context 'Given valid parameters' do
    context 'and required parameters only' do
      it 'should pass validation' do
        result = subject.call(required_params)

        expect(result.success?).to be_truthy
        expect(result.to_h).to eq required_params
      end
    end
  end
end
