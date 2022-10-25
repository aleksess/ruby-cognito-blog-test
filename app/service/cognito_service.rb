class CognitoService
    @@instance = nil

    def self.GetInstance
        if @@instance == nil
            @@instance = CognitoService.new
        end
        
        return @@instance
    end

    def sign_up(user)
        create_response = @client.sign_up({
            client_id: ENV['AWS_COGNITO_CLIENT_ID'],
            username: user[:username],
            password: user[:password],
            user_attributes: [
                {
                    name: "email",
                    value: user[:email]
                }
            ]
        })
    end

    def sign_in(credentials)
        sign_in_resp = @client.admin_initiate_auth({
            auth_flow: "ADMIN_NO_SRP_AUTH",
            user_pool_id: ENV['AWS_COGNITO_USER_POOL'], 
            client_id: ENV['AWS_COGNITO_CLIENT_ID'],
            auth_parameters: {
                "USERNAME" => credentials.username,
                "PASSWORD" => credentials.password
            }
        })

        return sign_in_resp
    end

    def refresh_tokens(refresh_token)
        refresh_token_resp = @client.admin_initiate_auth({
            auth_flow: "REFRESH_TOKEN_AUTH",
            user_pool_id: ENV['AWS_COGNITO_USER_POOL'], 
            client_id: ENV['AWS_COGNITO_CLIENT_ID'],
            auth_parameters: {
                "REFRESH_TOKEN" => refresh_token
            }
        })

        return refresh_token_resp
    end

    def revoke_token(refresh_token)
        @client.revoke_token({
            token: refresh_token,
            client_id: ENV['AWS_COGNITO_CLIENT_ID']
        })
    end



    private
    def initialize
        @client = Aws::CognitoIdentityProvider::Client.new(
            region: ENV['AWS_REGION'],
            credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
        )
    end
end