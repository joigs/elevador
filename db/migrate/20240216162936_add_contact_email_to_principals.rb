class AddContactEmailToPrincipals < ActiveRecord::Migration[7.1]
  def change
    add_column :principals, :contact_email, :string
  end
end
