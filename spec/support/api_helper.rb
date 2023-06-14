require 'faker'
require 'factory_bot_rails'

module ApiHelpers
    def authenticated_header(request, user)
        auth_headers = Devise::JWT::TestHelpers.auth_headers({}, user)
        request.headers.merge!(auth_headers)
    end

    def login_with_api(user)
        post '/login', params: {
            user: {
                email: user.email,
                password: user.password
            }
        }
    end
end