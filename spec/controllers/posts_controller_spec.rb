require 'rails_helper'

RSpec.describe PostsController, type: :request do

    describe 'GET #index' do
        let(:community) { create(:community) }
        let(:request_url) { "/api/communities/#{community.id}/posts"}

        context 'when the community has posts' do

            before do
                populate_community_with_posts(community, 5)
                get request_url
            end

            it 'should return status 200' do
                expect(response.status).to be(200)
            end

            it 'the response should include the community\'s posts' do
                expect(JSON.parse(response.body)['data'][0]).to have_key('title')
            end

        end

        context 'when the community has no posts' do
            before do
                get request_url
            end

            it 'should return status 204' do
                expect(response.status).to be (204)
            end
        end

    end

    describe 'GET #user_posts' do
        let(:user) { create(:user) }
        let(:request_url) { "/api/users/#{user.id}/posts"}


        context 'when the community has posts' do

            before do
                populate_user_with_posts(user, 5)
                get request_url
            end

            it 'should return status 200' do
                expect(response.status).to be(200)
            end

            it 'the response should include the users\'s posts' do
                #maybe map over resposne.body and check for each post to have user_id: user.id
                expect(JSON.parse(response.body)['data'][0]).to have_key('title')
            end

        end

        context 'when the community has no posts' do
            before do
                get request_url
            end

            it 'should return status 204' do
                expect(response.status).to be (204)
            end
        end
    end

end