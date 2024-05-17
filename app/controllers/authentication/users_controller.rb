class Authentication::UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    unless Current.user&.admin?
      redirect_to home_path, alert: "No tienes permiso"
      return
    end

    if user_params[:password].present? && user_params[:password_confirmation].present?
      unless user_params[:password] == user_params[:password_confirmation]
        flash.now[:alert] = "Las contraseñas no coinciden"
        @user = User.new(user_params.except(:password, :password_confirmation))
        render :new, status: :unprocessable_entity
        return
      end
    else
      @user = User.new(user_params.except(:password, :password_confirmation))
      flash.now[:alert] = "Debe llenar ambos campos de contraseña"
      render :new, status: :unprocessable_entity
      return
    end

    @user = User.new(user_params)
    if @user.save
      redirect_to user_path(@user), notice: "Usuario creado exitosamente"
    else
      render :new, status: :unprocessable_entity
    end
  end



  def index
    if Current.user&.admin
      @users = User.all
      if params[:query_text].present?
        @users = @users.filter(text: params[:query_text])
      end

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
    elsif Current.user.id == params[:id].to_i
      @user = User.find(params[:id])
    else
      redirect_to home_path, alert: "No tienes permiso"
    end
  end

  def update
    if Current.user&.admin
      @user = User.find(params[:id])

      if user_params[:password].present? && user_params[:password_confirmation].present?
        unless user_params[:password] == user_params[:password_confirmation]
          flash.now[:alert] = "Las contraseñas no coinciden"
          render :edit, status: :unprocessable_entity
          return
        end
      end

      if @user.update(user_params)
        redirect_to home_path, notice: "Usuario actualizado exitosamente"
      else
        render :edit, status: :unprocessable_entity
      end
    elsif Current.user.id == params[:id].to_i
      @user = User.find(params[:id])

      if user_params[:admin].present? || user_params[:real_name].present?
        redirect_to home_path, alert: "No tienes permiso para modificar estos campos"
        return
      end

      if user_params[:password].present? && user_params[:password_confirmation].present?
        unless user_params[:password] == user_params[:password_confirmation]
          flash.now[:alert] = "Las contraseñas no coinciden"
          render :edit, status: :unprocessable_entity
          return
        end
      end

      if @user.update(user_params)
        redirect_to perfil_path(@user.username), notice: "Usuario actualizado exitosamente"
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
    params.require(:user).permit(:username, :password, :real_name, :email, :admin, :password_confirmation, :signature, :profesion)
  end

end