module Api
  module V1
    class FacturacionsController < ApplicationController
      skip_before_action :protect_pages
      before_action :authenticate_api_key!

      def index
        @facturacions = Facturacion.where.not(number: 0)
        render json: @facturacions
      end

      private

      def authenticate_api_key!
        provided_key = request.headers['X-API-KEY'] || params[:api_key]
        unless provided_key.present? && ActiveSupport::SecurityUtils.secure_compare(provided_key, ENV['API_KEY'])
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      end
    end
  end
end
