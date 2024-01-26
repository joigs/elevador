class CreateMinors < ActiveRecord::Migration[7.1]
  def change
    create_table :minors do |t|
      t.string :rut
      t.string :name, null: false
      t.string :business_name
      t.string :contact_name
      t.string :email
      t.string :phone
      t.string :cellphone

      t.timestamps
    end
  end
end
