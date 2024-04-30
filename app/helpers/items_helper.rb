module ItemsHelper
  def last_inspection(item)
    item.inspections.order(created_at: :desc).first
  end
end
