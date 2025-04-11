require 'e2e/api/api_helper'

RSpec.describe 'Sleep Tracking Flow', type: :e2e do
  let(:user_params) { { name: 'Test User', email: 'test@example.com', password: 'password123' } }
  let(:friend_params) { { name: 'Friend User', email: 'friend@example.com', password: 'password123' } }

  it 'allows a user to track sleep and view friends sleep records' do
    # Step 1: Sign up
    post '/auth/sign_up', params: user_params
    expect(response).to have_http_status(:ok)
    user_id = json_response['id']
    user_token = Infrastructure::Services::JwtService.encode(user_id: user_id)

    # Step 2: Sign up friend
    post '/auth/sign_up', params: friend_params
    expect(response).to have_http_status(:ok)
    friend_id = json_response['id']
    friend_token = Infrastructure::Services::JwtService.encode(user_id: friend_id)

    # Step 3: Clock in sleep for friend
    post '/sleep_records', headers: auth_headers(friend_token)
    expect(response).to have_http_status(:created)
    sleep_record_id = json_response.first['id']

    # Wait for a short period
    sleep(1)

    # Step 4: Clock out sleep for friend
    patch "/sleep_records/#{sleep_record_id}", headers: auth_headers(friend_token)
    expect(response).to have_http_status(:ok)

    # Step 5: Follow friend
    post "/users/me/follow/#{friend_id}", headers: auth_headers(user_token)
    expect(response).to have_http_status(:ok)

    # Step 6: View friend's sleep records
    get '/users/me/following_sleep_records', headers: auth_headers(user_token)
    expect(response).to have_http_status(:ok)
    expect(json_response['data']).to be_an(Array)
    expect(json_response['data'].length).to eq(1)
    expect(json_response['data'].first['user_id']).to eq(friend_id)

    # Step 7: Unfollow friend
    delete "/users/me/follow/#{friend_id}", headers: auth_headers(user_token)
    expect(response).to have_http_status(:ok)

    # Step 8: Verify friend's sleep records are no longer visible
    get '/users/me/following_sleep_records', headers: auth_headers(user_token)
    expect(response).to have_http_status(:ok)
    expect(json_response['data']).to be_empty
  end
end 