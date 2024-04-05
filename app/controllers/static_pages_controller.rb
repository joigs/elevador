class StaticPagesController < ApplicationController
  def warnings
    current_date = Date.today
    two_months_later = current_date + 2.months

    # Get inspections with 'Aprobado' result and within the date range
    @inspections = Inspection.where(result: 'Aprobado').where("ins_date > ? AND ins_date <= ?", current_date, two_months_later)

    # Paginate the result
    @pagy, @inspections = pagy_countless(@inspections, items: 10)
  end
end
