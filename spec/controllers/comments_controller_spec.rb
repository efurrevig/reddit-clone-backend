require 'rails_helper'

RSpec.describe CommentsController, type: :request do

    describe 'POST #create' do
        let(:user) { create(:user) }
        let(:community) { create(:community) }
        let(:post_) { create(:post, user: user, community: community) }

        context 'when it is a top-level comment' do
            let(:comment) { build(:comment, user: user, post: post_) }
            let(:invalid_comment) { build(:comment, user: user, post: post_, body: nil)}
            context 'when the request is valid' do
                before do
                    create_comment_api(post_, comment, user)
                end

                it 'returns the comment' do
                    expect(JSON.parse(response.body)['data']['body']).to eq(comment.body)
                end

                it 'returns status code 200' do
                    expect(response.status).to be(200)
                end

                it 'creates the comment' do
                    expect(Comment.count).to eq(1)
                end
            end

            context 'when the request is invalid' do
                before do
                    create_comment_api(post_, invalid_comment, user)
                end

                it 'returns status code 422' do
                    expect(response).to have_http_status(422)
                end

                it 'returns a validation failure message' do
                    expect(JSON.parse(response.body)['errors'][0]).to eq("Body can't be blank")
                end
            end
        end

        context 'when it is a child comment' do
            let(:parent_comment) { create(:comment, user: user, post: post_) }
            let(:comment) { build(:comment, user: user, post: post_, parent_comment_id: parent_comment.id) }
            let(:invalid_comment) { build(:comment, user: user, post: post_, parent_comment_id: parent_comment.id, body: nil)}

            context 'when the request is valid' do
                before do
                    create_comment_api(post_, comment, user)
                end

                it 'returns the comment' do
                    expect(JSON.parse(response.body)['data']['parent_comment_id']).to eq(parent_comment.id)
                end

                it 'returns status code 200' do
                    expect(response.status).to be(200)
                end

                it 'creates the comment' do
                    expect(Comment.count).to eq(2)
                end
            end

            context 'when the comment has no text' do
                before do
                    create_comment_api(post_, invalid_comment, user)
                end

                it 'returns status code 422' do
                    expect(response).to have_http_status(422)
                end

                it 'returns a validation failure message' do
                    expect(JSON.parse(response.body)['errors'][0]).to eq("Body can't be blank")
                end
            end

            context 'when the parent comment does not exist' do
                let(:comment) { build(:comment, user: user, post: post_, parent_comment_id: 999) }
                before do
                    create_comment_api(post_, comment, user)
                end

                it 'returns status code 422' do
                    expect(response).to have_http_status(422)
                end

                it 'returns a validation failure message' do
                    expect(JSON.parse(response.body)['errors'][0]).to eq("Parent comment must be associated with an existing comment on the same post")
                end
            end
        end
    end

    describe 'PUT #update' do
        let(:user) { create(:user) }
        let(:community) { create(:community) }
        let(:post_) { create(:post, user: user, community: community) }
        let(:comment) { create(:comment, user: user, post: post_) }
        let(:body) { 'This is an updated comment' }
        
        context 'when the comment exists' do
            context 'when the request is valid' do
                before do
                    update_comment_api(comment, body, user)
                end

                it 'returns the comment' do
                    expect(JSON.parse(response.body)['data']['body']).to eq(body)
                end

                it 'returns status code 200' do
                    expect(response.status).to be(200)
                end
            end

            context 'when the request is invalid' do
                before do
                    update_comment_api(comment, nil, user)
                end

                it 'returns status code 422' do
                    expect(response).to have_http_status(422)
                end

                it 'returns a validation failure message' do
                    expect(JSON.parse(response.body)['errors'][0]).to eq("Body can't be blank")
                end
            end
        end

        context 'when the comment does not exist' do
            before do
                patch "/api/comments/999", params: {
                    comment: {
                        body: body
                    }
                }, headers: authenticated_header(user)
            end

            it 'returns status code 404' do
                expect(response).to have_http_status(404)
            end
        end

        context 'when the user is not the owner of the comment' do
            let(:user2) { create(:user) }
            before do
                update_comment_api(comment, body, user2)
            end

            it 'returns status code 403' do
                expect(response).to have_http_status(403)
            end
        end

    end

    describe 'DELETE #destroy' do
        let(:user) { create(:user) }
        let(:community) { create(:community) }
        let(:post_) { create(:post, user: user, community: community) }
        let(:comment) { create(:comment, user: user, post: post_) }

        context 'when the comment exists' do
            before do
                delete "/api/comments/#{comment.id}", headers: authenticated_header(user)
            end

            it 'returns status code 204' do
                expect(response).to have_http_status(204)
            end

            it 'updates the comment' do
                expect(comment.reload.is_deleted?).to be(true)
            end
        end

        context 'when the comment does not exist' do
            before do
                delete "/api/comments/999", headers: authenticated_header(user)
            end

            it 'returns status code 404' do
                expect(response).to have_http_status(404)
            end
        end

        context 'when the user is not the owner of the comment' do
            let(:user2) { create(:user) }
            before do
                delete "/api/comments/#{comment.id}", headers: authenticated_header(user2)
            end

            it 'returns status code 403' do
                expect(response).to have_http_status(403)
            end
        end
    end

end