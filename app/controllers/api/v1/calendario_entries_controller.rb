module Api
  module V1
    class CalendarioEntriesController < CalendarioBaseController

      def index
        mes = params[:mes].to_i
        anio = params[:anio].to_i

        fecha_inicio = Date.new(anio, mes, 1)
        fecha_fin = fecha_inicio.next_month

        entradas = CalendarEntry.joins(:user)
                                .where(entry_date: fecha_inicio...fecha_fin)
                                .where(users: { deleted_at: nil })
                                .select('calendar_entries.*, users.username, users.real_name')

        resultado = entradas.group_by { |e| e.entry_date.strftime("%Y-%m-%d") }.transform_values do |entries|
          entries.map do |e|
            {
              id: e.id,
              user_id: e.user_id,
              content: e.content,
              username: e.username,
              real_name: e.real_name.presence || e.username,
              updated_at: e.updated_at
            }
          end
        end

        render json: resultado
      end

      def create
        entry = CalendarEntry.find_or_initialize_by(
          user_id: @current_user.id,
          entry_date: params[:entry_date]
        )
        entry.content = params[:content]

        if entry.save
          render json: { success: true, entry: entry }
        else
          render json: { success: false, errors: entry.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        entry = CalendarEntry.find_by(
          user_id: @current_user.id,
          entry_date: params[:entry_date]
        )

        if entry&.destroy
          render json: { success: true }
        else
          render json: { success: false, message: 'Entrada no encontrada o no tienes permisos para borrarla' }, status: :not_found
        end
      end
    end
  end
end