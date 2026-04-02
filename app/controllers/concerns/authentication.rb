module Authentication
  extend ActiveSupport::Concern
  included do
    before_action :set_current_user
    before_action :protect_pages
    before_action :restrict_relleno_access

    private

    def set_current_user
      Current.user = User.find_by(id: session[:user_id]) if session[:user_id]
    end

    def protect_pages
      unless Current.user
        flash[:alert] = "Debe iniciar sesión"
        redirect_to new_session_path
      end
    end

    def restrict_relleno_access
      return unless Current.user&.relleno?

      allowed =
        (controller_path == "authentication/users" && %w[edit_relleno update_relleno].include?(action_name)) ||
          (controller_path == "authentication/sessions" && %w[destroy].include?(action_name))

      unless allowed
        flash[:alert] = "No tienes permiso"
        redirect_to edit_relleno_users_path
      end
    end
  end
end