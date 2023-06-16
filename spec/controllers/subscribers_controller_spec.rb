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

    context 'When subscribing to a community' do
        let!(:community) { create(:community) }
        let(:request_url) { "/api/communities/#{community.id}/subscribers"}

        context 'When the user is logged in' do
            let(:user) { create(:user) }
            let(:auth_header) { authenticated_header(user) }
        
            context 'when the user_id is correct' do
                let!(:initial_subscribers) { Subscriber.count }

                before do
                    subscribe_to_community(user, community, auth_header)
                end

                it 'should return status 200' do
                    expect(response.status).to eq(200)
                end

                it 'should add a subscriber' do
                    expect(Subscriber.count).to eq(initial_subscribers + 1)
                end

                it 'should exist in the database from communities' do
                    expect(
                        community.subscribers.exists?(user_id: user.id)
                    ).to be true
                end

                it 'should exist in the database from user' do
                    expect(
                        user.subscriptions.exists?(community_id: community.id)
                    ).to be true
                end
            end

            context 'when the user_id is wrong' do
                let!(:initial_subscribers) { Subscriber.count }
                let(:wrong_user) { create(:user) }

                before do
                    subscribe_to_community(wrong_user, community, auth_header)
                end

                it 'should return status 422' do
                    expect(response.status).to be(422)
                end

                it 'should not create a subscriber' do
                    expect(Subscriber.count).to eq(initial_subscribers)
                end
            end

            context 'when the user is already subscribed' do
                before do
                    create(:subscriber, community: community, user: user)
                    subscribe_to_community(user, community, auth_header)
                end

                it 'should return status 422' do
                    expect(response.status).to eq(422)
                end

                it 'should have correct error message' do
                    expect(JSON.parse(response.body)['status']['message']['user_id']).to eq(['has already subscribed to community'])
                end
            end
        end

        context 'when the user is not logged in' do
            let(:user) { create(:user) }
            before do
                post request_url, params: {
                    subscriber: {
                        user_id: user.id
                    }
                }
            end

            it 'should return status 401' do
                expect(response.status).to eq(401)
            end

        end

    end

end