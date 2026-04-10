module Api
  module V1
    class CalendarioBaseController < ApplicationController
      skip_before_action :verify_authenticity_token, raise: false
      skip_before_action :protect_pages, raise: false
      skip_before_action :restrict_relleno_access, raise: false

      before_action :verify_api_key
      before_action :authenticate_request

      private

      def verify_api_key
        api_key = request.headers['X-API-KEY']
        valid_key = ENV['EXPO_API_KEY']

        unless api_key == valid_key
          render json: { error: 'Acceso denegado: API Key inválida o ausente' }, status: :unauthorized
        end
      end

      def authenticate_request
        header = request.headers['Authorization']
        token = header.split(' ').last if header

        begin
          decoded = decode_token(token)
          @current_user = User.find_by(id: decoded[:user_id], deleted_at: nil)

          unless @current_user
            render json: { error: 'Usuario no encontrado o eliminado' }, status: :unauthorized
          end
        rescue JWT::DecodeError, NoMethodError
          render json: { error: 'No autorizado: Token inválido o expirado' }, status: :unauthorized
        end
      end

      def encode_token(payload, exp = 24.hours.from_now)
        payload[:exp] = exp.to_i
        JWT.encode(payload, Rails.application.secret_key_base.to_s)
      end

      def decode_token(token)
        decoded = JWT.decode(token, Rails.application.secret_key_base.to_s)[0]
        HashWithIndifferentAccess.new(decoded)
      end
    end
  end
end