class UsersController < ApplicationController
  skip_before_action :validate_session

  def new
  end

  def create

    User.transaction do
      cognitoDto = {username: params[:name], email: params[:email], password: params[:password]}

      CognitoService.GetInstance.sign_up cognitoDto

      @user = User.new(name: params[:name])

      if @user.save
        redirect_to '/'
      else
        render :new, status: :unprocessable_entity
      end
    end
    
  end

  private 
    def create_user_params
      params.require(:name, :password, :email)
    end
end
