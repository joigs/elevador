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
      flash[:notice] = "Usuario creado exitosamente"
      redirect_to user_path(@user)
    else
      render :new, status: :unprocessable_entity
    end
  end



  def index
    if Current.user&.admin
      @q = User.ransack(params[:q])
      @users = @q.result(distinct: true)

      @pagy, @users = pagy_countless(@users, items: 10)
    else
      flash[:alert] = "No tienes permiso"
      redirect_to home_path
    end
  end


  def show
    if Current.user&.admin
      @user = User.find(params[:id])
    else
      flash[:alert] = "No tienes permiso"
      redirect_to home_path
    end
  end
  def edit
    if Current.user&.admin
      @user = User.find(params[:id])
    elsif Current.user.id == params[:id].to_i
      @user = User.find(params[:id])
    else
      flash[:alert] = "No tienes permiso"
      redirect_to home_path
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
        flash[:notice] = "Usuario modificado"
        redirect_to home_path
      else
        render :edit, status: :unprocessable_entity
      end
    elsif Current.user.id == params[:id].to_i
      @user = User.find(params[:id])

      if user_params[:admin].present? || user_params[:real_name].present?
        flash[:alert] = "No tienes permiso para modificar estos campos"
        redirect_to home_path
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
        flash[:notice] = "Usuario modificado"
        redirect_to home_path
      else
        render :edit, status: :unprocessable_entity
      end
    else
      flash[:alert] = "No tienes permiso"
      redirect_to home_path
    end
  end


  def destroy
    if Current.user&.admin
      @user = User.find(params[:id])
      @user.destroy
      flash[:notice] = "Usuario eliminado exitosamente"
      respond_to do |format|
        format.html { redirect_to users_path }
        format.turbo_stream { head :no_content }
      end    else
      flash[:alert] = "no tienes permiso"
      redirect_to home_path
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :password, :real_name, :email, :admin, :password_confirmation, :profesion)
  end

end