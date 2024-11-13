module ItemsHelper
  def last_inspection(item)
    item.inspections.order(number: :desc).first
  end
end
