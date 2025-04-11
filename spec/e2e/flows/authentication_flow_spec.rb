require 'e2e/api/api_helper'

RSpec.describe 'Authentication Flow', type: :e2e do
  let(:valid_user_params) { { name: 'Test User', email: 'test@example.com', password: 'password123' } }
  let(:invalid_user_params) { { name: 'Test User', email: 'invalid_email', password: '123' } }

  describe 'Sign Up Flow' do
    it 'successfully signs up a new user' do
      post '/auth/sign_up', params: valid_user_params
      expect(response).to have_http_status(:ok)
      expect(json_response).to include('id', 'name', 'email')
      expect(json_response['email']).to eq(valid_user_params[:email])
    end

    it 'fails to sign up with invalid email format' do
      post '/auth/sign_up', params: invalid_user_params
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['error']).to include('email')
    end

    it 'fails to sign up with duplicate email' do
      # First sign up
      post '/auth/sign_up', params: valid_user_params
      expect(response).to have_http_status(:ok)

      # Try to sign up with same email
      post '/auth/sign_up', params: valid_user_params
      expect(response).to have_http_status(:conflict)
      expect(json_response['error']).to eq('Email already registered.')
    end
  end

  describe 'Sign In Flow' do
    before do
      # Create a user first
      post '/auth/sign_up', params: valid_user_params
      @user_id = json_response['id']
    end

    it 'successfully signs in with correct credentials' do
      post '/auth/sign_in', params: { email: valid_user_params[:email], password: valid_user_params[:password] }
      expect(response).to have_http_status(:ok)
      expect(json_response).to include('token')
      
      # Verify token is valid by accessing a protected endpoint
      token = json_response['token']
      get '/users/me', headers: auth_headers(token)
      expect(response).to have_http_status(:ok)
      expect(json_response['id']).to eq(@user_id)
    end

    it 'fails to sign in with incorrect password' do
      post '/auth/sign_in', params: { email: valid_user_params[:email], password: 'wrong_password' }
      expect(response).to have_http_status(:unauthorized)
      expect(json_response['error']).to eq('Invalid credentials.')
    end

    it 'fails to sign in with non-existent email' do
      post '/auth/sign_in', params: { email: 'nonexistent@example.com', password: valid_user_params[:password] }
      expect(response).to have_http_status(:unauthorized)
      expect(json_response['error']).to eq('Invalid credentials.')
    end
  end

  describe 'Token Validation' do
    before do
      # Create a user and get a valid token
      post '/auth/sign_up', params: valid_user_params
      @user_id = json_response['id']
      post '/auth/sign_in', params: { email: valid_user_params[:email], password: valid_user_params[:password] }
      @valid_token = json_response['token']
    end

    it 'rejects requests with invalid token format' do
      get '/users/me', headers: auth_headers('invalid_token')
      expect(response).to have_http_status(:unauthorized)
      expect(json_response['error']).to eq('Unauthorized: Invalid or expired token.')
    end

    it 'rejects requests with expired token' do
      # Create an expired token by modifying the payload
      payload = JWT.decode(@valid_token, Infrastructure::Services::JwtService::SECRET_KEY, true, { algorithm: Infrastructure::Services::JwtService::ALGORITHM }).first
      payload['exp'] = Time.now.to_i - 3600 # 1 hour ago
      expired_token = JWT.encode(payload, Infrastructure::Services::JwtService::SECRET_KEY, Infrastructure::Services::JwtService::ALGORITHM)

      get '/users/me', headers: auth_headers(expired_token)
      expect(response).to have_http_status(:unauthorized)
      expect(json_response['error']).to eq('Unauthorized: Invalid or expired token.')
    end

    it 'rejects requests without token' do
      get '/users/me'
      expect(response).to have_http_status(:unauthorized)
      expect(json_response['error']).to eq('Unauthorized: Missing Authorization header')
    end
  end
end 