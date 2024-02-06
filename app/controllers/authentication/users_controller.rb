class Authentication::UsersController < ApplicationController

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
      redirect_to home_path, alert: "No tienes permiso"
    end
  end

  def index
    if Current.user&.admin
      @users = User.all
      @pagy, @users = pagy_countless(@users, items: 10)
    else
      redirect_to home_path, alert: "No tienes permiso"
    end
  end

  def show
    if Current.user&.admin
      @user = User.find(params[:id])
    else
      redirect_to home_path, alert: "No tienes permiso"
    end
  end
  def edit
    if Current.user&.admin
      @user = User.find(params[:id])
    else
      redirect_to home_path, alert: "No tienes permiso"
    end
  end

  def update
    if Current.user&.admin
      @user = User.find(params[:id])

      if @user.update(user_params)
        redirect_to home_path, notice: "Usuario actualizado exitosamente"
      else
        render :edit, status: :unprocessable_entity
      end
    else
      redirect_to home_path, alert: "No tienes permiso"
    end
  end

  def destroy
    if Current.user&.admin
      @user = User.find(params[:id])
      @user.destroy
      redirect_to home_path, notice: "Usuario eliminado exitosamente"
    else
      redirect_to home_path, alert: "No tienes permiso"
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :password, :real_name, :email, :admin)
  end

end