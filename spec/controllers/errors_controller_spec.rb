require 'rails_helper'

RSpec.describe ErrorsController, type: :controller do
  describe 'GET #not_found' do
    it 'returns 404 status with error message' do
      get :not_found
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)).to eq({ 'error' => 'Not Found' })
    end

    it 'returns JSON content type' do
      get :not_found
      expect(response.content_type).to eq('application/json; charset=utf-8')
    end

    it 'handles different request formats' do
      get :not_found, format: :json
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)).to eq({ 'error' => 'Not Found' })
    end

    it 'includes CORS headers' do
      get :not_found
      expect(response.headers['Access-Control-Allow-Origin']).to eq('*')
      expect(response.headers['Access-Control-Allow-Methods']).to eq('GET, POST, PUT, PATCH, DELETE, OPTIONS')
      expect(response.headers['Access-Control-Allow-Headers']).to eq('Origin, Content-Type, Accept, Authorization, Token')
    end
  end

  describe 'GET #internal_server_error' do
    it 'returns 500 status with error message' do
      get :internal_server_error
      expect(response).to have_http_status(:internal_server_error)
      expect(JSON.parse(response.body)).to eq({ 'error' => 'Internal Server Error' })
    end

    it 'returns JSON content type' do
      get :internal_server_error
      expect(response.content_type).to eq('application/json; charset=utf-8')
    end

    it 'handles different request formats' do
      get :internal_server_error, format: :json
      expect(response).to have_http_status(:internal_server_error)
      expect(JSON.parse(response.body)).to eq({ 'error' => 'Internal Server Error' })
    end

    it 'includes CORS headers' do
      get :internal_server_error
      expect(response.headers['Access-Control-Allow-Origin']).to eq('*')
      expect(response.headers['Access-Control-Allow-Methods']).to eq('GET, POST, PUT, PATCH, DELETE, OPTIONS')
      expect(response.headers['Access-Control-Allow-Headers']).to eq('Origin, Content-Type, Accept, Authorization, Token')
    end
  end

  describe 'Error handling with parameters' do
    it 'handles not_found with path parameter' do
      get :not_found, params: { path: 'invalid/path' }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)).to eq({ 'error' => 'Not Found' })
    end

    it 'handles internal_server_error with error details' do
      get :internal_server_error, params: { error: 'Test error' }
      expect(response).to have_http_status(:internal_server_error)
      expect(JSON.parse(response.body)).to eq({ 'error' => 'Internal Server Error' })
    end
  end
end 