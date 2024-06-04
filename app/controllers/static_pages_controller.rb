class StaticPagesController < ApplicationController
  def warnings
    inspections_scope = case params[:filter]
                        when "expiring_soon"
                          Inspection.joins(:report)
                                    .where("reports.ending > ?", Date.today)
                                    .where("reports.ending <= ?", Date.today + 2.months)
                                    .where(state: 'Cerrado')
                        when "vencido"
                          Inspection.where(result: 'Vencido')
                        else
                          Inspection.none
                        end

    @q = inspections_scope.ransack(params[:q])
    @inspections = @q.result(distinct: true)
    @pagy, @inspections = pagy_countless(@inspections, items: 10)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
