class Authentication::SessionsController < ApplicationController

  skip_before_action :protect_pages

  def new

    if Current.user
      flash[:alert] = "Ya tienes una sesion activa"

      redirect_to home_path
    end

  end

  def create



    @user = User.find_by("username = :login", {login: params[:login]})

    if @user&.authenticate(params[:password])
      session[:user_id] = @user.id
      flash[:notice] = "Bienvenido"
      redirect_to home_path
    else
      redirect_to new_session_path, alert: "Credenciales invalidas"
    end

  end

  def destroy
    session.delete(:user_id)
    flash[:notice] = "Sesion cerrada"
    redirect_to new_session_path
  end

  private


end