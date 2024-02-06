class UpdateEmailColumnInUsers < ActiveRecord::Migration[7.1]
  def up
    User.where(email: nil).update_all(email: 'default@example.com')
  end

  def down
    # Revert the changes if needed
  end
end
