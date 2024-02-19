class AddCertAntToReports < ActiveRecord::Migration[7.1]
  def change
    add_column :reports, :cert_ant, :string
  end
end
