require 'rails_helper'

RSpec.describe SubscribersController, type: :request do

    context 'When getting subscriber count' do
        let!(:community) { create(:community) }
        let(:request_url) { "/api/communities/#{community.id}/subscribers" }

        before do
            3.times do
                create(:subscriber, community: community)
            end
            get request_url  
        end

        it 'should return status 200' do
            expect(response.status).to eq(200)
        end

        it 'should return data 3' do
            expect(JSON.parse(response.body)['data']).to eq(3)
        end

    end
end