class AddCommentToPlatRevisionRulesPlats < ActiveRecord::Migration[7.1]
  def change
    add_column :plat_revision_rules_plats, :comment, :text
  end
end
