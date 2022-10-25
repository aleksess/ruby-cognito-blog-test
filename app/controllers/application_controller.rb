class ApplicationController < ActionController::Base

    before_action :validate_session

    private
        def validate_session
            unless session[:access_token]
                session[:refresh_token] = nil
                session[:username] = nil
                redirect_to '/auth/sign_in'
                return
            end

            aws_idp = Faraday.get("https://cognito-idp.#{ENV['AWS_REGION']}.amazonaws.com/#{ENV['AWS_COGNITO_USER_POOL']}/.well-known/jwks.json").body
            jwt_config = JSON.parse(aws_idp, symbolize_names: true)

            begin 
                JWT.decode session[:access_token], nil, true, {jwks: jwt_config, algorithms: ['RS256'] }
            rescue JWT::ExpiredSignature
                refresh_session
            rescue 
                session[:access_token] = nil
                session[:refresh_token] = nil
                session[:username] = nil
                redirect_to '/auth/sign_in'
            end
            
        end

        def refresh_session
            begin
                resp = CognitoService.GetInstance.refresh_token(session[:refresh_token])

                session[:access_token] = resp.authentication_result.access_token
                session[:refresh_token] = resp.authentication_result.refresh_token
            rescue 
                render :sign_in_page, status: :unauthorized
            end
        end
end
