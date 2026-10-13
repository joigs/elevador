class RemoveContactoFromPrincipals < ActiveRecord::Migration[7.1]
  def change
    remove_column :principals, :place, :string
    remove_column :principals, :contact_name, :string
    remove_column :principals, :contact_email, :string
    remove_column :principals, :cellphone, :string
  end
end
