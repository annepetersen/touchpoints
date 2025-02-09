# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::CxResponsesController, type: :controller do
  describe 'unauthenticated request' do
    before do
      get :index
    end

    it 'get access denied due to HTTP Basic Auth' do
      expect(response.status).to eq(401)
    end
  end

  describe 'authenticated request, using HTTP_AUTH' do
    describe 'without passing ?API_KEY' do
      before do
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV.fetch('API_HTTP_USERNAME'), ENV.fetch('API_HTTP_PASSWORD'))
        get :index, format: :json
      end

      it 'get access denied due to HTTP Basic Auth' do
        parsed_response = JSON.parse(response.body)
        expect(response.status).to eq(400)
        expect(parsed_response['error']['message']).to eq('Invalid request. No ?API_KEY= was passed in.')
      end
    end

    describe 'passing an invalid API_KEY' do
      before do
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV.fetch('API_HTTP_USERNAME'), ENV.fetch('API_HTTP_PASSWORD'))
        get :index, format: :json, params: { 'API_KEY' => 'INVALID_KEY' }
      end

      it 'get access denied due to HTTP Basic Auth' do
        parsed_response = JSON.parse(response.body)
        expect(response.status).to eq(401)
        expect(parsed_response['error']['message']).to eq('The API_KEY INVALID_KEY is not valid.')
      end
    end

    context "with uploads" do
      let!(:user) { FactoryBot.create(:user) }
      let!(:organization1) { FactoryBot.create(:organization) }
      let!(:service_provider) { FactoryBot.create(:service_provider, organization: organization1) }
      let!(:service) { FactoryBot.create(:service, organization: organization1, service_provider: service_provider, service_owner_id: user.id) }
      let!(:cx_collection) { FactoryBot.create(:cx_collection, organization: organization1, service_provider: service_provider, service: service, user: user) }
      let!(:cx_collection_detail) { FactoryBot.create(:cx_collection_detail, :with_cx_collection_detail_upload, cx_collection: cx_collection, service: service) }
      let!(:cx_response) { CxResponse.first }

      describe '#index' do
        before do
          user.update(api_key: TEST_API_KEY)
          request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV.fetch('API_HTTP_USERNAME'), ENV.fetch('API_HTTP_PASSWORD'))
          get :index, format: :json, params: { 'API_KEY' => user.api_key }
          @parsed_response = JSON.parse(response.body)
        end

        it 'return a default paginated array of cx_responses' do
          expect(response.status).to eq(200)
          expect(@parsed_response['data'].class).to be(Array)
          expect(@parsed_response['data'].size).to eq(500)
          expect(@parsed_response['data'].first.class).to be(Hash)
          expect(@parsed_response['data'].first["type"]).to eq("cx_responses")
          expect(@parsed_response['data'].first['id']).to eq(cx_response.id.to_s)
        end
      end

      describe 'pagination' do
        before do
          user.update(api_key: TEST_API_KEY)
          request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV.fetch('API_HTTP_USERNAME'), ENV.fetch('API_HTTP_PASSWORD'))
          get :index, format: :json, params: { 'API_KEY' => user.api_key, "page[size]" => 100, "page[number]" => 10 }
          @parsed_response = JSON.parse(response.body)
        end

        it 'return the last paginated array of 100 cx_responses' do
          expect(response.status).to eq(200)
          expect(@parsed_response['data'].class).to be(Array)
          expect(@parsed_response['data'].size).to eq(100)
          expect(@parsed_response['data'].last.class).to be(Hash)
          expect(@parsed_response['data'].last["type"]).to eq("cx_responses")
          expect(@parsed_response['data'].last['id']).to eq(CxResponse.last.id.to_s)
        end
      end
    end

  end
end
