# app/controllers/api/v1/facturacions_controller.rb

module Api
  module V1
    class FacturacionsController < ApplicationController
      skip_before_action :protect_pages
      before_action :authenticate_api_key!

      # GET /api/v1/facturacions
      # app/controllers/api/v1/facturacions_controller.rb
      def index
        facturacions = Facturacion.where.not(number: 0).where.not(oc: nil).distinct

        year, month, empresa = params.values_at(:year, :month, :empresa)

        if year.present? || month.present?
          facturacions = facturacions.joins(:inspections)
                                     .where.not(inspections: { ins_date: nil })
        end
        facturacions = facturacions.where("YEAR(inspections.ins_date) = ?", year)   if year.present?
        facturacions = facturacions.where("MONTH(inspections.ins_date) = ?", month) if month.present?
        facturacions = facturacions.select { |f| f.empresa == empresa }             if empresa.present?

        if params[:meta].present?
          years     = Inspection.where.not(ins_date: nil)
                                .pluck(Arel.sql('DISTINCT YEAR(ins_date)'))
                                .sort
          empresas  = Facturacion.distinct.pluck(:empresa).compact.sort
          render json: {   anios: years,
                           meses: (1..12).to_a,
                           empresas: empresas }
          return
        end

        render json: facturacions.as_json(
          include: { inspections: { include: :principal } },
          methods: [:fecha_inspeccion, :empresa]
        )
      end



      # GET /api/v1/facturacions/:id
      def show
        @facturacion = Facturacion.find(params[:id])

        render json: @facturacion.as_json(
          include: {
            inspections: {
              include: :principal
            }
          },
          methods: [:fecha_inspeccion, :empresa]
        )
      end

      private

      def authenticate_api_key!
        provided_key = request.headers['X-API-KEY'] || params[:api_key]
        expected_key = ENV['VERTICAL_API_KEY']

        Rails.logger.warn "[API_KEY] provided=#{provided_key.inspect}(#{provided_key&.bytesize}) "\
                            "expected=#{expected_key.inspect}(#{expected_key&.bytesize})"


        unless provided_key.present? &&
          expected_key.present? &&
          provided_key.bytesize == expected_key.bytesize &&
          ActiveSupport::SecurityUtils.secure_compare(provided_key, expected_key)
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end


    end
  end
end
