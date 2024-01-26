class AddPrincipalReferenceToMinors < ActiveRecord::Migration[7.1]
  def change
    add_reference :minors, :principal, null: false, foreign_key: true
  end
end
