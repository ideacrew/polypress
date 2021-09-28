# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Accounts::Create, type: :request do
  subject { described_class.new }

  context 'Given a Keycloak client configuration with credentials and network-accessible Keycloak instance' do
    it 'should connect to the server' do
      # Keycloak.proc_cookie_token = lambda { cookies[:keycloak_token] }
      token = JSON(Keycloak::Client.get_token_by_client_credentials)

      expect(token['access_token']).not_to be_nil
      expect(token['token_type']).to eq 'Bearer'
    end
  end

  context 'Creating a Keycloak Account' do
    before do
      Keycloak.proc_cookie_token =
        Keycloak::Client.get_token_by_client_credentials
    end

    after do
      # Delete user
    end

    context 'Given valid parameters for a new user' do
      let(:username) { 'ironman' }
      let(:password) { '$3cr3tP@55w0rd' }
      let(:email) { 'tony.stark@avengers.org' }
      let(:first_name) { 'Tony' }
      let(:last_name) { 'Stark' }

      let(:required_params) do
        {
          username: username,
          password: password,
          email: email,
          first_name: first_name,
          last_name: last_name
        }
      end

      it 'should create the new user' do
        response = subject.call(required_params)
        binding.pry

        expect(response.success?).to be_truthy
      end
    end
  end
end
