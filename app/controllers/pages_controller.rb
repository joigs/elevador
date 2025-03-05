class PagesController < ApplicationController

  def bash_fill
      @items = Item
                 .joins(:group)
                 .where(groups: { type_of: "ascensor" })
                 .includes(:detail, inspections: :report)

      @inspections = @items.map { |item| item.inspections.max_by(&:number) }.compact

      @inspections = @inspections.sort_by(&:number).reverse

  end



end