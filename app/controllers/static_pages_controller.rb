class StaticPagesController < ApplicationController
  def warnings
    params[:filter] ||= "expiring_soon"
    inspections_scope = case params[:filter]
                        when "expiring_soon"
                          Inspection.joins(:report)
                                    .where("reports.ending > ?", Date.today)
                                    .where("reports.ending <= ?", Date.today + 2.months)
                                    .where(state: 'Cerrado').where(result: 'Aprobado')
                                    .includes(:report)
                        when "vencido"
                          Inspection.where(result: 'Vencido')
                        else
                          Inspection.none
                        end

    @q = inspections_scope.ransack(params[:q])
    @inspections = @q.result(distinct: true)
    unless Current.user.tabla

      @pagy, @inspections = pagy_countless(@inspections, items: 10) # Paginación infinita para las tarjetas
    end
    @filter = params[:filter]
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
