module Api
  module V1
    class SessionsController < BaseController
      def create
        user = User.find_by(username: params[:username], deleted_at: nil)

        if user&.authenticate(params[:password])
          render json: {
            success: true,
            user: {
              id: user.id,
              username: user.username,
              real_name: user.real_name.presence || user.username,
            }
          }
        else
          render json: { success: false, message: 'Credenciales inválidas' }, status: :unauthorized
        end
      end
    end
  end
end