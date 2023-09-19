require "rails_helper"

RSpec.describe Rack::Attack, type: :request do

    include ActiveSupport::Testing::TimeHelpers

    before do
        Rack::Attack.enabled = true
        Rack::Attack.reset!
    end

    after do
        Rack::Attack.enabled = false
    end

    describe 'throttle excessive requests by IP address' do
        let(:limit) { 100 }
        it 'successful for 100 requests, then throttled on the 101st' do
            limit.times do
                get '/api/communities'
                expect(response.status).to eq(200)
            end
            get '/api/communities'
            expect(response.status).to eq(429)
        end

        it 'succeeds after throttle period' do
            limit.times do
                get '/api/communities'
                expect(response.status).to eq(200)
            end
            travel_to(2.minutes.from_now) do
                get '/api/communities'
                expect(response.status).to eq(200)
            end
        end

        it 'search should not be throttled on 101st request' do
            limit.times do
                get '/api/communities/'
                expect(response.status).to eq(200)
            end
            get '/api/communities/search/test'
            expect(response.status).to eq(200)
        end
    end

end