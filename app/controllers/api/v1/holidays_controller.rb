module Api
  module V1
    class HolidaysController < CalendarioBaseController

      def index
        mes = params[:mes].to_i
        anio = params[:anio].to_i

        fecha_inicio = Date.new(anio, mes, 1)
        fecha_fin = fecha_inicio.next_month

        fechas = Holiday.where(holiday_date: fecha_inicio...fecha_fin)
                        .pluck(:holiday_date)
                        .map { |d| d.strftime('%Y-%m-%d') }

        render json: fechas
      end
    end
  end
end
