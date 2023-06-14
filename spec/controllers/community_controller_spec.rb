require 'rails_helper'

RSpec.describe CommunitiesController, type: :request do
    let(:user) { create(:user) }
    let(:request_url) { '/api/communities' }
  
    describe 'GET #index' do
      it 'returns a success response' do
        get request_url
        expect(response).to have_http_status(:success)
      end
  
      it 'assigns all communities as @communities' do
        community1 = create(:community)
        community2 = create(:community)
  
        get request_url
        expect(controller.instance_variable_get(:@communities)).to match_array([community1, community2])
      end
    end
  
    describe 'POST #create' do

      context 'when authenticated' do
        let(:auth_header) {authenticated_header(user)}
        let(:initial_count) { 0 }

        context 'with valid parameters' do
          let(:community) { build(:community) }
          before do
            initial_count = Community.count
            post request_url, params: {
              community: {
                name: community.name
              }
            }, headers: auth_header
          end
          
          it 'creates a new community' do
            expect(Community.count).to eq(initial_count + 1)
          end
  
          it 'returns a success response' do
            expect(response.status).to be(200)
          end
  
          it 'returns the created community' do
            expect(JSON.parse(response.body)['data']['name']).to eq(community.name)
          end
        end
  
        context 'with invalid parameters' do
          before do
            initial_count = Community.count 
            post request_url, params: {
              community: {
                name: ''
              }
            }, headers: auth_header
          end
  
          it 'does not create a new community' do
            expect(Community.count).to eq(initial_count)
          end
  
          it 'returns an error response' do
            expect(response.status).to be(422)
          end
  
          it 'returns the error messages' do
            expect(JSON.parse(response.body)['status']['code']).to be(422)
            expect(JSON.parse(response.body)['status']['message']).to_not be_empty
          end
        end
      end
  
      context 'when not authenticated' do
        it 'returns an unauthorized response' do
          post request_url
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  
    describe 'DELETE #destroy' do
      let(:auth_header) {authenticated_header(user)}
      let!(:community) { create(:community) }
      let!(:initial_count) { Community.count }
      let!(:destroy_url) { "/api/communities/#{community.id}"}

      context 'when authenticated' do
        before do
          delete destroy_url, headers: auth_header
        end

        it 'destroys the requested community' do
          expect(Community.count).to be(initial_count - 1)
        end
  
        it 'returns a success response' do
          expect(response.status).to be(200)
        end
  
        it 'returns the success message' do
          expect(JSON.parse(response.body)['status']['message']).to eq('Community successfully removed.')
        end
      end
  
      context 'when not authenticated' do
        it 'returns an unauthorized response' do
          delete destroy_url
          expect(response.status).to be(401)
        end
      end
    end
  end