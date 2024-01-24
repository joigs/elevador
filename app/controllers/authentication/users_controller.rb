class Authentication::UsersController < ApplicationController

    skip_before_action :protect_pages
  def new
    @user = User.new
  end

  def create
    if Current.user&.admin
      @user = User.new(user_params)

      if @user.save
        redirect_to home_path, notice: "Usuario creado exitosamente"
      else
        render :new, status: :unprocessable_entity
      end
    else
      redirect_to new_session_path, alert: "No tienes permiso"
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :password, :real_name)
  end

end