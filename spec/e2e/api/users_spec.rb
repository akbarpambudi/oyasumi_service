require 'e2e/api/api_helper'

RSpec.describe 'Users API', type: :e2e do
  let(:user) { create(:user_record) }
  let(:token) { Infrastructure::Services::JwtService.encode(user_id: user.id) }

  describe 'GET /users' do
    context 'when authenticated' do
      it 'returns a paginated list of users' do
        create_list(:user_record, 3)

        get '/users', headers: auth_headers(token)

        expect(response).to have_http_status(:ok)
        expect(json_response['data']).to be_an(Array)
        expect(json_response['meta']['total']).to eq(4) # including the authenticated user
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        get '/users'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /users/:id' do
    context 'when authenticated' do
      it 'returns the user details' do
        get "/users/#{user.id}", headers: auth_headers(token)

        expect(response).to have_http_status(:ok)
        expect(json_response['id']).to eq(user.id)
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        get "/users/#{user.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /users/me/follow/:id' do
    let(:other_user) { create(:user_record) }

    context 'when authenticated' do
      it 'follows another user successfully' do
        post "/users/me/follow/#{other_user.id}", headers: auth_headers(token)

        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('Followed successfully')
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        post "/users/me/follow/#{other_user.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /users/me/follow/:id' do
    let(:other_user) { create(:user_record) }

    context 'when authenticated' do
      before do
        post "/users/me/follow/#{other_user.id}", headers: auth_headers(token)
      end

      it 'unfollows another user successfully' do
        delete "/users/me/follow/#{other_user.id}", headers: auth_headers(token)

        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('Unfollowed successfully')
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        delete "/users/me/follow/#{other_user.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end 