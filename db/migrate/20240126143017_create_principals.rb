class CreatePrincipals < ActiveRecord::Migration[7.1]
  def change
    create_table :principals do |t|
      t.string :rut, null: false
      t.string :name, null: false
      t.string :business_name, null: false
      t.string :contact_name
      t.string :email, null: false
      t.string :phone
      t.string :cellphone

      t.timestamps
    end
  end
end
