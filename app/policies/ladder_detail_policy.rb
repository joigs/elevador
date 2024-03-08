class LadderDetailPolicy < BasePolicy
  def method_missing(m, *args, &block)
    item = Item.find(record.item_id)
    item.inspector?
  end
end