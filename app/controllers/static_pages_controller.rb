class StaticPagesController < ApplicationController
  def warnings
    case params[:filter]
    when "expiring_soon"
      @pagy, @inspections = pagy_countless(
        Inspection.where(result: 'Aprobado')
                  .where("DATE_ADD(ins_date, INTERVAL validation YEAR) <= ?", Date.today + 2.months),
        items: 10
      )
    when "vencido"
      @pagy, @inspections = pagy_countless(
        Inspection.where(result: 'Vencido'),
        items: 10
      )
    else
      # Handle default case or render a specific message or redirect
      @pagy, @inspections = pagy_countless(Inspection.none, items: 10)
    end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
