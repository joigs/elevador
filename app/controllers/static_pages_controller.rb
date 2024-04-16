class StaticPagesController < ApplicationController
  def warnings



    # Use a custom scope to filter the inspections within the next two months without converting to an array
    @pagy, @inspections = pagy_countless(
      Inspection.where(result: 'Aprobado')
                .where("DATE_ADD(ins_date, INTERVAL validation YEAR) <= ?", Date.today + 2.months),
      items: 10
    )
  end
end
