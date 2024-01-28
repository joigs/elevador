module ItemsHelper
  def last_inspection(item)
    item.inspections.last
  end
end
