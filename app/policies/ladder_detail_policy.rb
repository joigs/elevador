class LadderDetailPolicy < BasePolicy

  def edit
    item = Item.find(record.item_id)
    item.inspector? || Current.user.admin
  end
  def update
    item = Item.find(record.item_id)
    item.inspector? || Current.user.admin

  end


  def method_missing(m, *args, &block)
    item = Item.find(record.item_id)
    item.inspector?
  end
end