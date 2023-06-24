require 'rails_helper'

RSpec.describe CommentsController, type: :request do

    describe 'POST #create' do
        let(:user) { create(:user) }
        let(:community) { create(:community) }
        let(:post_) { create(:post, user: user, community: community) }

        context 'when it is a top-level comment' do
            let(:comment) { build(:comment_of_post, user: user, commentable: post_) }
            let(:invalid_comment) { build(:comment_of_post, user: user, commentable: post_, body: nil)}
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
            let(:parent_comment) { create(:comment_of_post, user: user, commentable: post_) }
            let(:comment) { build(:comment_of_comment, user: user, commentable: parent_comment ) }
            let(:invalid_comment) { build(:comment_of_comment, user: user, commentable: parent_comment, body: nil)}

            context 'when the request is valid' do
                before do
                    create_comment_api(parent_comment, comment, user)
                end

                it 'returns the comment' do
                    expect(JSON.parse(response.body)['data']['commentable_id']).to eq(parent_comment.id)
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
                    create_comment_api(parent_comment, invalid_comment, user)
                end

                it 'returns status code 422' do
                    expect(response).to have_http_status(422)
                end

                it 'returns a validation failure message' do
                    expect(JSON.parse(response.body)['errors'][0]).to eq("Body can't be blank")
                end
            end

            context 'when the parent comment does not exist' do
                before do
                    post '/api/comments/999/comments', params: {
                        comment: {
                            body: 'This is a comment',
                            user_id: user.id,
                            commentable_type: 'Comment',
                            commentable_id: 999
                        }
                    }, headers: authenticated_header(user)
                end

                it 'returns status code 404' do
                    expect(response).to have_http_status(404)
                end

            end
        end
    end

    describe 'PUT #update' do
        let(:user) { create(:user) }
        let(:community) { create(:community) }
        let(:post_) { create(:post, user: user, community: community) }
        let(:comment) { create(:comment_of_post, user: user, commentable: post_) }
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
        let(:comment) { create(:comment_of_post, user: user, commentable: post_) }

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

    describe 'POST #upvote' do
        context 'when the user is signed in' do
            let(:user) { create(:user) }
            let!(:comment) { create(:comment_of_post, user: user) }
            let(:request_url) { "/api/comments/#{comment.id}/upvote" }

            context 'when the user has not voted on the comment' do
                before do
                    post request_url, headers: authenticated_header(user)
                end

                it 'returns status code 204' do
                    expect(response).to have_http_status(204)
                end

                it 'creates the vote' do
                    expect(Vote.find_by(votable_type: 'Comment', votable_id: comment.id, user_id: user.id).value).to be(1)
                end

                it 'the comment should have a vote value of 1' do
                    expect(Comment.find(comment.id).votes.sum(:value)).to be(1)
                end
            end

            context 'when the user has already upvoted the comment' do
                before do
                    post request_url, headers: authenticated_header(user)
                    post request_url, headers: authenticated_header(user)
                end

                it 'returns status code 204' do
                    expect(response).to have_http_status(204)
                end

                it 'the comment should have a vote value of 0' do
                    expect(Comment.find(comment.id).votes.sum(:value)).to be(0)
                end
            end

            context 'when the user has already downvoted the comment' do
                let!(:vote) { create(:vote, votable: comment, user: user, value: -1) }
                before do
                    post request_url, headers: authenticated_header(user)
                end

                it 'returns status code 204' do
                    expect(response).to have_http_status(204)
                end

                it 'the comment should have a vote value of 1' do
                    expect(Comment.find(comment.id).votes.sum(:value)).to be(1)
                end

                it 'the vote should have a value of 1' do
                    expect(Vote.find(vote.id).value).to be(1)
                end
            end

        end

        context 'when the user is not signed in' do
            let(:comment) { create(:comment_of_post) }
            before do
                post "/api/comments/#{comment.id}/upvote"
            end

            it 'returns status code 401' do
                expect(response).to have_http_status(401)
            end
        end

    end

    describe 'POST #downvote' do
        context 'when the user is signed in' do
            let(:user) { create(:user) }
            let!(:comment) { create(:comment_of_post, user: user) }
            let(:request_url) { "/api/comments/#{comment.id}/downvote" }

            context 'when the user has not voted on the comment' do
                before do
                    post request_url, headers: authenticated_header(user)
                end

                it 'returns status code 204' do
                    expect(response).to have_http_status(204)
                end

                it 'creates the vote' do
                    expect(Vote.find_by(votable_type: 'Comment', votable_id: comment.id, user_id: user.id).value).to be(-1)
                end

                it 'the comment should have a vote value of -1' do
                    expect(Comment.find(comment.id).votes.sum(:value)).to be(-1)
                end
            end

            context 'when the user has already downvoted the comment' do
                before do
                    post request_url, headers: authenticated_header(user)
                    post request_url, headers: authenticated_header(user)
                end

                it 'returns status code 204' do
                    expect(response).to have_http_status(204)
                end

                it 'the comment should have a vote value of 0' do
                    expect(Comment.find(comment.id).votes.sum(:value)).to be(0)
                end
            end

            context 'when the user has already upvoted the comment' do
                let!(:vote) { create(:vote, votable: comment, user: user, value: 1) }
                before do
                    post request_url, headers: authenticated_header(user)
                end

                it 'returns status code 204' do
                    expect(response).to have_http_status(204)
                end

                it 'the comment should have a vote value of -1' do
                    expect(Comment.find(comment.id).votes.sum(:value)).to be(-1)
                end

                it 'the vote should have a value of -1' do
                    expect(Vote.find(vote.id).value).to be(-1)
                end
            end

        end

        context 'when the user is not signed in' do
            let(:comment) { create(:comment_of_post) }
            before do
                post "/api/comments/#{comment.id}/downvote"
            end

            it 'returns status code 401' do
                expect(response).to have_http_status(401)
            end
        end
    end

end