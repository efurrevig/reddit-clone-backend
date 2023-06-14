require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :request do

    let(:user) { build(:user) }
    let(:existing_user) { create(:user) }
    let(:signup_url) { '/api/signup' }
    

    context 'When creating a user' do
        before do
            post signup_url, params: {
                user: {
                    username: user.username,
                    email: user.email,
                    password: user.password
                }
            }
        end

        it 'returns 200' do
            expect(response.status).to eq(200)
        end

        it 'returns a token' do
            expect(response.headers['Authorization']).to be_present
        end

        it 'returns the user email and username' do
            expect(JSON.parse(response.body)['data']['username']).to eq(user.username)
            expect(JSON.parse(response.body)['data']['email']).to eq(user.email)
        end
    end

    context 'When the email already exists' do
        before do
            post signup_url, params: {
                user: {
                    username: 'temp_username_2039',
                    email: existing_user.email,
                    password: existing_user.password
                }
            }
        end

        it 'returns 422' do
            expect(response.status).to eq(422)
        end

        it 'returns the correct message' do
            expect(JSON.parse(response.body)['status']['message']).to eq('Email has already been taken')
        end
    end
    
end