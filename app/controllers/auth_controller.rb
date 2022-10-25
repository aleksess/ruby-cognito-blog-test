class AuthController < ApplicationController

  skip_before_action :validate_session, only: [:sign_in_page, :sign_in]

  def sign_in_page
     @credentials = Credentials.new
  end


  def sign_in
    begin
      if session[:access_token]
        redirect_to '/'
      end


      @credentials = Credentials.new(username: sign_in_params[:username], password: sign_in_params[:password])

      if !@credentials.valid?
        render :sign_in_page, status: :bad_request
      end

      cognitoResp = CognitoService.GetInstance.sign_in @credentials

      if !cognitoResp.authentication_result
        render :sign_in_page, status: :unauthorized
      end

      user = User.find_by(name: sign_in_params[:username])
      
      session[:access_token] = cognitoResp.authentication_result.access_token
      session[:refresh_token] = cognitoResp.authentication_result.refresh_token
      session[:username] = user.name

      redirect_to '/'
    rescue Aws::CognitoIdentityProvider::Errors::NotAuthorizedException => e
      render :sign_in_page, status: :unauthorized
    end
  end

  def sign_out
    CognitoService.GetInstance.revoke_token session[:refresh_token]
    session[:access_token] = nil
    session[:refresh_token] = nil
    session[:username] = nil

    redirect_to '/'
  end

  private
    def sign_in_params
      params.require(:credentials).permit(:username, :password)
    end
end
