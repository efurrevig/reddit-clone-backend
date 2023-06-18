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

    context 'when unsubscribing from a community' do
        let(:user) { create(:user) }
        let(:community) { create(:community) }
        let!(:subscriber) { create(:subscriber, community: community, user: user) }

        context 'when the user is logged in' do
            let(:auth_header) { authenticated_header(user) }
            let!(:initial_count) { Subscriber.count }

            before do
                unsubscribe_to_community(subscriber, community, auth_header)
            end

            it 'should return status 204' do
                expect(response.status).to eq(202)
            end

            it 'should return the correct message' do
                expect(JSON.parse(response.body)['status']['message']).to eq('has successfully unsubscribed')
            end

            it 'should remove a subscriber from the db' do
                expect(Subscriber.count).to eq(initial_count - 1)
            end

            it 'should remove the correct subscriber' do
                expect(Subscriber.exists?(subscriber.id)).to be false
            end
        end

        context 'when the user is not logged in' do
            let!(:initial_count) { Subscriber.count }

            before do
                delete "/api/communities/#{community.id}/subscribers/#{subscriber.id}"
            end

            it 'should return status 401' do
                expect(response.status).to eq(401)
            end

            it 'should not delete a subscriber' do
                expect(Subscriber.count).to eq(initial_count)
            end
        end
    end

    context 'when changing a users status' do
        let(:user_to_change) { create(:user) }
        let(:community) { create(:community) }
        let(:sub_to_change) { create(:subscriber, user: user_to_change, community: community) }
        let(:admin) { create(:user) }
        let!(:admin_sub) { create(:subscriber, user: admin, community: community, status: :admin) }

        # context 'when the requesting user is an admin' do
        #     let(:auth_header) { authenticated_header(admin) }

        #     before do
        #         change_sub_status(:moderator, sub_to_change, community, auth_header)
        #     end

        #     it 'should return status 204' do
        #         expect(response.status).to be(204)
        #     end

        #     it 'should edit the subscriber' do
        #         expect(Subscriber.exists?(id: sub_to_change.id, status: :moderator)).to be true
        #     end
        # end

        context 'when the requesting user is not an admin' do
            let(:mod) { create(:user) }
            let!(:mod_sub) { create(:subscriber, user: mod, community: community, status: :moderator) }
            let(:approved) { create(:user) }
            let!(:app_sub) { create(:subscriber, user: approved, community: community, status: :approved)}
            let(:member) { create(:user) }
            let!(:mem_sub) { create(:subscriber, user: member, community: community, status: :member) }
            let(:non_sub) { create(:user) }

            context 'when user is a mod' do
                let!(:auth_header) { authenticated_header(mod) }
                before do
                    change_sub_status(:moderator, sub_to_change, community, auth_header)
                end

                it 'should return status 422' do
                    expect(response.status).to be(422)
                end

                it 'should not change the sub' do
                    expect(Subscriber.exists?(id: sub_to_change.id, status: :moderator)).to be false
                end
            end

            context 'when user is approved' do
                let!(:auth_header) { authenticated_header(approved) }
                before do
                    change_sub_status(:moderator, sub_to_change, community, auth_header)
                end

                it 'should return status 422' do
                    expect(response.status).to be(422)
                end

                it 'should not change the sub' do
                    expect(Subscriber.exists?(id: sub_to_change.id, status: :moderator)).to be false
                end
            end

            context 'when user is a member' do
                let!(:auth_header) { authenticated_header(member) }
                before do
                    change_sub_status(:moderator, sub_to_change, community, auth_header)
                end

                it 'should return status 422' do
                    expect(response.status).to be(422)
                end

                it 'should not change the sub' do
                    expect(Subscriber.exists?(id: sub_to_change.id, status: :moderator)).to be false
                end
            end

            context 'when user is not subbed' do
                let!(:auth_header) { authenticated_header(non_sub) }
                before do
                    change_sub_status(:moderator, sub_to_change, community, auth_header)
                end

                it 'should return status 422' do
                    expect(response.status).to be(422)
                end

                it 'should not change the sub' do
                    expect(Subscriber.exists?(id: sub_to_change.id, status: :moderator)).to be false
                end
            end
        end

    end

end