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
                expect(JSON.parse(response.body)['data'].map { |post| post['user_id'] }).to all(be(user.id))
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

    describe 'GET #show' do

        context 'when the post exists' do
            let(:post) { create(:post) }
            let(:request_url) { "/api/communities/#{post.community.id}/posts/#{post.id}"}
            before do
                get request_url
            end

            it 'should return status 200' do
                expect(response.status).to be(200)
            end

            it 'the response should include the post' do
                expect(JSON.parse(response.body)['data']['title']).to eq(post.title)
            end
        end

        context 'when the post does not exist' do
            let(:community) { create(:community) }
            let(:request_url) { "/api/communities/#{community.id}/posts/1"}
            before do
                get request_url
            end

            it 'should return status 404' do
                expect(response.status).to be (404)
            end
        end

    end

    describe 'POST #create' do

        context 'when the user is signed in' do
            let(:user) { create(:user) }

            context 'when the post is valid' do
                let(:community) { create(:community) }
                let(:new_post) { build(:post) }

                before do
                    create_post_api(community, new_post, user)
                end

                it 'it should return status 201' do
                    expect(response.status).to be(201)
                end

                it 'it should return the post' do
                    expect(JSON.parse(response.body)['data']['title']).to eq(new_post.title)
                end
            end

            context 'when the post is invalid' do
                let(:community) { create(:community) }
                let(:new_post) { build(:post, title: nil) }

                before do
                    create_post_api(community, new_post, user)
                end

                it 'it should return status 422' do
                    expect(response.status).to be(422)
                end

                it 'it should return the posts errors' do
                    expect(JSON.parse(response.body)['status']['message']).to include("Please fill out all required fields")
                end
            end
        end

        context 'when the user is not signed in' do
            let(:community) { create(:community) }
            let(:new_post) { build(:post) }

            before do
                create_post_api(community, new_post, nil)
            end

            it 'it should return status 401' do
                expect(response.status).to be(401)
            end
        end
    end

    describe 'DELETE #destroy' do
        context 'when the user is signed in' do
            let(:user) { create(:user) }

            context 'when the user is the owner of the post' do
                let(:post) { create(:post, user: user) }
                let(:request_url) { "/api/communities/#{post.community.id}/posts/#{post.id}"}

                before do
                    delete request_url, headers: authenticated_header(user)
                end

                it 'should return status 204' do
                    expect(response.status).to be(204)
                end
            end

            context 'when the user is not the owner of the post' do
                let(:post) { create(:post) }
                let(:request_url) { "/api/communities/#{post.community.id}/posts/#{post.id}"}

                before do
                    delete request_url, headers: authenticated_header(user)
                end

                it 'should return status 403' do
                    expect(response.status).to be(403)
                end
            end

            context 'when the post does not exist' do
                let(:community) { create(:community) }
                let(:request_url) { "/api/communities/#{community.id}/posts/1"}

                before do
                    delete request_url, headers: authenticated_header(user)
                end

                it 'should return status 404' do
                    expect(response.status).to be(404)
                end
            end
        end

        context 'when the user is not signed in' do
            let(:post) { create(:post) }
            let(:request_url) { "/api/communities/#{post.community.id}/posts/#{post.id}"}

            before do
                delete request_url, headers: nil
            end

            it 'should return status 401' do
                expect(response.status).to be(401)
            end
        end
    end

    describe 'PATCH #update' do

        context 'when the user is signed in' do
            
            let(:user) { create(:user) }

            context 'when the user is the owner of the post' do
                let(:post) { create(:post, user: user) }
                let(:edited_post) { build(:post) }

                before do
                    edit_post_api(post.community, post, edited_post, user)
                end

                it 'should return status 200' do
                    expect(response.status).to be(200)
                end

                it 'should return the updated post' do
                    expect(JSON.parse(response.body)['data']['title']).to eq(edited_post.title)
                end
            end

            context 'when the user is not the owner of the post' do
                let(:post) { create(:post) }
                let(:edited_post) { build(:post) }

                before do
                    edit_post_api(post.community, post, edited_post, user)
                end

                it 'should return status 403' do
                    expect(response.status).to be(403)
                end
            end

            context 'when the post does not exist' do
                let(:community) { create(:community) }
                let(:edited_post) { build(:post) }
                let(:request_url) { "/api/communities/#{community.id}/posts/1" }

                before do
                    patch request_url, params: {
                        post: {
                            title: edited_post.title,
                            body: edited_post.body,
                            post_type: edited_post.post_type,
                        }
                    }, headers: authenticated_header(user)
                end

                it 'should return status 404' do
                    expect(response.status).to be(404)
                end
            end
        end

        context 'when the user is not signed in' do
            let(:post) { create(:post) }
            let(:edited_post) { build(:post) }

            before do
                edit_post_api(post.community, post, edited_post, nil)
            end

            it 'should return status 401' do
                expect(response.status).to be(401)
            end
        end


    end

end