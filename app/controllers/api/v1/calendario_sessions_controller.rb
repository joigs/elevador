module Api
  module V1
    class CalendarioSessionsController < CalendarioBaseController
      skip_before_action :authenticate_request, only: [:create]

      def create
        user = User.find_by(username: params[:username], deleted_at: nil)

        if user&.authenticate(params[:password])
          token = encode_token(user_id: user.id)

          render json: {
            success: true,
            token: token,
            user: {
              id: user.id,
              username: user.username,
              real_name: user.real_name.presence || user.username,
              relleno: user.respond_to?(:relleno?) ? user.relleno? : false
            }
          }
        else
          render json: { success: false, message: 'Credenciales inválidas' }, status: :unauthorized
        end
      end
    end
  end
end