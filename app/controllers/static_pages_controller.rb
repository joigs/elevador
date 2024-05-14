class StaticPagesController < ApplicationController
  def warnings
    case params[:filter]
    when "expiring_soon"
      @pagy, @inspections = pagy_countless(
        Inspection.joins(:report)
                  .where("reports.ending > ?", Date.today)
                  .where("reports.ending <= ?", Date.today + 2.months)
                  .where(state: 'Cerrado'),
        items: 10
      )
    when "vencido"
      @pagy, @inspections = pagy_countless(
        Inspection.where(result: 'Vencido'),
        items: 10
      )
    else
      @pagy, @inspections = pagy_countless(Inspection.none, items: 10)
    end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
