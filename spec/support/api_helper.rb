require 'faker'
require 'factory_bot_rails'

module ApiHelpers
    def authenticated_header(user)
        Devise::JWT::TestHelpers.auth_headers({}, user)
    end

    def login_with_api(user)
        post '/api/login', params: {
            user: {
                email: user.email,
                password: user.password
            }
        }
    end
end