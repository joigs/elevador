class AddPrincipalIdToItems < ActiveRecord::Migration[7.1]
  def change
    add_reference :items, :principal, null: false, foreign_key: true
  end
end
