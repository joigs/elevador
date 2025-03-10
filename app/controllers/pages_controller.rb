class PagesController < ApplicationController

  def bash_fill
      @items = Item
                 .joins(:group)
                 .where(groups: { type_of: "ascensor" })
                 .includes(:detail, inspections: :report)

      @inspections = @items.map { |item| item.inspections.max_by(&:number) }.compact

      @inspections = @inspections.sort_by(&:number).reverse

  end

  def bash_fill_detail
    if params[:inspection_numbers].present?
      numbers = params[:inspection_numbers].split(',')
      @inspections = Inspection.where(number: numbers)
    else
      flash[:alert] = "No se ingresaron inspecciones"
      redirect_to bash_fill_path
    end
  end

end