class Authentication::PasswordResetsController < ApplicationController
  skip_before_action :protect_pages

  def new
  end

  MAX_POR_EMAIL = 2

  def create
    email = params[:email].to_s.strip.downcase

    if limite_alcanzado?(email)
      redirect_to new_password_reset_path, alert: mensaje_limite
      return
    end

    user = User.where("LOWER(email) = ?", email).first if email.present?

    registrar_intento(email)

    if user && user.email.present? && !user.relleno?
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

  private

  def limite_alcanzado?(email)
    return false if email.blank?

    contador(clave_email(email)) >= MAX_POR_EMAIL
  end

  def registrar_intento(email)
    return if email.blank?

    clave = clave_email(email)
    Rails.cache.write(clave, contador(clave) + 1, expires_in: segundos_hasta_manana)
  end

  def contador(clave)
    Rails.cache.read(clave).to_i
  end

  def clave_email(email)
    "pwreset:email:#{Date.current}:#{Digest::SHA256.hexdigest(email)}"
  end

  def segundos_hasta_manana
    (Date.current.tomorrow.beginning_of_day.in_time_zone - Time.current).to_i
  end

  def mensaje_limite
    "Alcanzaste el límite de solicitudes de recuperación de contraseña por hoy. " \
      "Podrás intentarlo nuevamente a partir de mañana. " \
      "Si necesitas acceder ahora, contacta a un administrador."
  end


end