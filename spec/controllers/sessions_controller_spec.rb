require 'rails_helper'

RSpec.describe Users::SessionsController, type: :request do

    let(:user) { create(:user) }
    let(:login_url) { '/api/login' }
    let(:logout_url) { '/api/logout' }

    context 'When logging in' do
        before do
            login_with_api(user)
        end

        it 'returns a token' do
            expect(response.headers['Authorization']).to be_present
        end

        it 'returns 200' do
            expect(response.status).to eq(200)
        end
    end

    context 'When password is missing' do
        before do
            post login_url, params: {
                user: {
                    email: user.email,
                    password: nil
                }
            }
        end

        it 'returns 401' do
            expect(response.status).to eq(401)
        end
    end

    context 'When logging out' do
        before do
            login_with_api(user)
        end

        it 'returns 200' do
            delete logout_url, headers: { 'Authorization' => response.headers['Authorization'] }
            expect(response.status).to be(200)
        end

        it 'changes users jti key' do
            initial_jti = user.jti
            delete logout_url, headers: { 'Authorization' => response.headers['Authorization'] }
            user.reload
            expect(user.jti).not_to eq(initial_jti)
        end
    end

    context 'When logging out without Authorization header' do
        before do
            login_with_api(user)
        end

        it 'returns 401' do
            delete logout_url
            expect(response.status).to be(401)
        end
    end

end