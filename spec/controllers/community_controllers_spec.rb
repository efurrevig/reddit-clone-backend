require 'rails_helper'

RSpec.describe CommunitiesController, type: :controller do
    let(:user) { create(:user) }
  
    describe 'GET #index' do
      it 'returns a success response' do
        get :index
        expect(response).to have_http_status(:success)
      end
  
      it 'assigns all communities as @communities' do
        community1 = create(:community)
        community2 = create(:community)
  
        get :index
        expect(controller.instance_variable_get(:@communities)).to match_array([community1, community2])
      end
    end
  
    describe 'POST #create' do
      context 'when authenticated' do
        before do
            auth_headers = Devise::JWT::TestHelpers.auth_headers({}, user)
            request.headers.merge!(auth_headers)
        end
  
        context 'with valid parameters' do
          let(:valid_params) { { community: attributes_for(:community) } }
  
          it 'creates a new community' do
            expect {
              post :create, params: valid_params
            }.to change(Community, :count).by(1)
          end
  
          it 'returns a success response' do
            post :create, params: valid_params
            expect(response).to have_http_status(:success)
          end
  
          it 'returns the created community' do
            post :create, params: valid_params
            expect(JSON.parse(response.body)['data']['name']).to eq(valid_params[:community][:name])
          end
        end
  
        context 'with invalid parameters' do
          let(:invalid_params) { { community: { name: nil } } }
  
          it 'does not create a new community' do
            expect {
              post :create, params: invalid_params
            }.to_not change(Community, :count)
          end
  
          it 'returns an error response' do
            post :create, params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end
  
          it 'returns the error messages' do
            post :create, params: invalid_params
            expect(JSON.parse(response.body)['status']['code']).to eq(422)
            expect(JSON.parse(response.body)['status']['message']).to_not be_empty
          end
        end
      end
  
      context 'when not authenticated' do
        it 'returns an unauthorized response' do
          post :create
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  
    describe 'DELETE #destroy' do
      let!(:community) { create(:community) }
  
      context 'when authenticated' do
        before { request.headers.merge!(authorization_header) }
  
        it 'destroys the requested community' do
          expect {
            delete :destroy, params: { id: community.id }
          }.to change(Community, :count).by(-1)
        end
  
        it 'returns a success response' do
          delete :destroy, params: { id: community.id }
          expect(response).to have_http_status(:success)
        end
  
        it 'returns the success message' do
          delete :destroy, params: { id: community.id }
          expect(JSON.parse(response.body)['status']['code']).to eq(200)
          expect(JSON.parse(response.body)['status']['message']).to eq('Community successfully removed.')
        end
      end
  
      context 'when not authenticated' do
        it 'returns an unauthorized response' do
          delete :destroy, params: { id: community.id }
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end