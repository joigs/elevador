class PasswordResetMailer < ApplicationMailer
  def reset(user, token)
    @user = user
    @url  = edit_password_reset_url(token)

    mail(
      from: email_address_with_name(ENV["RESET_SMTP_USER"], ENV.fetch("RESET_FROM_NAME", "CHCERT")),
      to: @user.email,
      subject: "Restablecer tu contraseña",
      delivery_method_options: smtp_propio
    )
  end

  private

  def smtp_propio
    {
      address:              ENV["RESET_SMTP_HOST"],
      port:                 ENV.fetch("RESET_SMTP_PORT", "465").to_i,
      user_name:            ENV["RESET_SMTP_USER"],
      password:             ENV["RESET_SMTP_PASSWORD"],
      authentication:       :plain,
      ssl:                  true,
      enable_starttls_auto: false
    }
  end
end