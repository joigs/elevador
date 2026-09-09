class Authentication::PasswordResetsController < ApplicationController
  skip_before_action :protect_pages

  def new
  end

  def create
    email = params[:email].to_s.strip.downcase
    user  = User.where("LOWER(email) = ?", email).first if email.present?

    if user && user.email.present? && user.puede_iniciar_sesion? && !user.relleno?
      token = user.generate_token_for(:password_reset)
      PasswordResetMailer.reset(user, token).deliver_later
    end

    redirect_to new_session_path,
                notice: "Si el correo está registrado, recibirás un enlace para restablecer tu contraseña."
  end

  def edit
    @user = User.find_by_token_for(:password_reset, params[:token])
    return if @user

    redirect_to new_password_reset_path, alert: "El enlace no es válido o ya expiró"
  end

  def update
    @user = User.find_by_token_for(:password_reset, params[:token])

    unless @user
      redirect_to new_password_reset_path, alert: "El enlace no es válido o ya expiró"
      return
    end

    if params[:user][:password].blank? || params[:user][:password_confirmation].blank?
      flash.now[:alert] = "Debe llenar ambos campos de contraseña"
      render :edit, status: :unprocessable_entity
      return
    end

    if params[:user][:password] != params[:user][:password_confirmation]
      flash.now[:alert] = "Las contraseñas no coinciden"
      render :edit, status: :unprocessable_entity
      return
    end

    if @user.update(password: params[:user][:password],
                    password_confirmation: params[:user][:password_confirmation])
      redirect_to new_session_path, notice: "Contraseña actualizada. Ya puedes iniciar sesión."
    else
      render :edit, status: :unprocessable_entity
    end
  end
end