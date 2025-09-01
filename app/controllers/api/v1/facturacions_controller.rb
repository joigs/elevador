# app/controllers/api/v1/facturacions_controller.rb

module Api
  module V1
    class FacturacionsController < ApplicationController
      skip_before_action :protect_pages
      before_action :authenticate_api_key!

      # GET /api/v1/facturacions
      def index
        facturacions = Facturacion.where.not(number: 0).distinct
        convenios = Convenio.all
        year, month = params.values_at(:year, :month)


        full_year   =  month.to_s == 'all'
        if full_year
          facturacions = Facturacion.where.not(number: 0).where.not(fecha_venta: nil).distinct
          convenios    = Convenio.all

          if year.present?
            year_i = year.to_i
            facturacions = facturacions.where("EXTRACT(YEAR FROM fecha_venta) = ?", year_i)
            convenios    = convenios.where("convenios.year = ?", year_i)
          end

          render json: {
            facturacions: facturacions.as_json(
              include: { inspections: { include: :principal } },
              methods: [:fecha_inspeccion, :empresa, :inspecciones_total_no_rerun]
            ),
            convenios: convenios.as_json(
              only: [:id, :fecha_venta, :n1, :v1, :empresa_id],
              methods: [:empresa_nombre]
            )
          }
        else
        facturacions = facturacions.where.not(fecha_venta: nil)

        if year.present?
          facturacions = facturacions.where("EXTRACT(YEAR FROM fecha_venta) = ?", year)
          convenios = convenios.where("convenios.year = ?", year)
        end

        if month.present?
          facturacions = facturacions.where("EXTRACT(MONTH FROM fecha_venta) = ?", month)
          convenios = convenios.where("convenios.month = ?", month)
        end

        if (!year.present? && !month.present?)
          facturacions = facturacions.where("EXTRACT(MONTH FROM fecha_venta) = ?", Date.today.month)
          convenios = convenios.where("convenios.month = ?", Date.today.month)
        end




        convenios = convenios.where("convenios.year = ?", year)   if year.present?
        convenios = convenios.where("convenios.month = ?", month) if month.present?






        render json: {
          facturacions: facturacions.as_json(
            include: {
              inspections: { include: :principal }
            },
            methods: [:fecha_inspeccion, :empresa, :inspecciones_total_no_rerun]
          ),
          convenios: convenios.as_json(
            only: [:id, :fecha_venta, :n1, :v1, :empresa_id],
            methods: [:empresa_nombre]
          )
        }
        end

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
