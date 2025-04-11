require 'rails_helper'
require 'bcrypt'

RSpec.describe Application::AuthAppService, type: :service do
  let(:user_repository) { instance_double(Domain::Repository::UserRepository) }
  let(:jwt_service) { class_double(Infrastructure::Services::JwtService).as_stubbed_const }

  subject(:auth_app_service) { described_class.new(user_repository) }

  let(:name) { 'John Doe' }
  let(:email) { 'john@example.com' }
  let(:plain_password) { 'some-password' }

  let(:user) do
    instance_double(
      Domain::Entities::User,
      id: 123,
      name: name,
      email: email,
      encrypted_password: 'hashed-secret',
      authenticate?: true
    )
  end

  describe '#sign_up' do
    it 'hashes the password and saves the user via the repository' do
      allow(user_repository).to receive(:save).and_return(user)

      auth_app_service.sign_up(
        name: name,
        email: email,
        plain_password: plain_password
      )

      expect(user_repository).to have_received(:save) do |saved_entity|
        expect(saved_entity.encrypted_password).not_to eq(plain_password)
        expect(saved_entity.name.value).to eq(name)
        expect(saved_entity.email.value).to eq(email)
      end
    end
  end

  describe '#sign_in' do
    let(:token) { 'jwt.token.value' }

    context 'when the user is found and password is correct' do
      before do
        allow(user_repository).to receive(:find_by_email)
          .with(email)
          .and_return(user)
        allow(jwt_service).to receive(:encode)
          .with({ user_id: user.id })
          .and_return(token)
      end

      it 'returns a JWT token' do
        expect(
          auth_app_service.sign_in(email: email, plain_password: plain_password)
        ).to eq(token)

        expect(user_repository).to have_received(:find_by_email)
          .with(email)
        expect(jwt_service).to have_received(:encode)
          .with({ user_id: user.id })
      end
    end

    context 'when the user is not found' do
      before do
        allow(user_repository).to receive(:find_by_email)
          .with(email)
          .and_return(nil)
      end

      it 'raises an InvalidCredentialsError' do
        expect {
          auth_app_service.sign_in(email: email, plain_password: plain_password)
        }.to raise_error(Domain::Errors::InvalidCredentialsError)
      end
    end

    context 'when the password is incorrect' do
      before do
        allow(user_repository).to receive(:find_by_email)
          .with(email)
          .and_return(user)
        allow(user).to receive(:authenticate?)
          .and_return(false)
      end

      it 'raises an InvalidCredentialsError' do
        expect {
          auth_app_service.sign_in(email: email, plain_password: plain_password)
        }.to raise_error(Domain::Errors::InvalidCredentialsError)
      end
    end
  end

  describe '#authenticate_token' do
    let(:valid_token) { 'valid.jwt.token' }
    let(:invalid_token) { 'invalid.jwt.token' }
    let(:decoded_token) { { 'user_id' => user.id } }

    context 'when the token is valid' do
      before do
        allow(jwt_service).to receive(:decode)
          .with(valid_token)
          .and_return(decoded_token)
        allow(user_repository).to receive(:find_by_id)
          .with(user.id)
          .and_return(user)
      end

      it 'returns the user' do
        expect(auth_app_service.authenticate_token(token: valid_token)).to eq(user)
      end
    end

    context 'when JwtService.decode fails' do
      before do
        allow(jwt_service).to receive(:decode)
          .with(invalid_token)
          .and_raise(Domain::Errors::InvalidTokenError)
      end

      it 'raises an InvalidTokenError' do
        expect {
          auth_app_service.authenticate_token(token: invalid_token)
        }.to raise_error(Domain::Errors::InvalidTokenError)
      end
    end

    context 'when the user is not found' do
      before do
        allow(jwt_service).to receive(:decode)
          .with(valid_token)
          .and_return(decoded_token)
        allow(user_repository).to receive(:find_by_id)
          .with(user.id)
          .and_raise(Domain::Errors::UserNotFoundError)
      end

      it 'raises an InvalidTokenError' do
        expect {
          auth_app_service.authenticate_token(token: valid_token)
        }.to raise_error(Domain::Errors::InvalidTokenError)
      end
    end
  end
end
