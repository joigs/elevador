class AddCertAntRealToReports < ActiveRecord::Migration[7.1]
  def change
    add_column :reports, :cert_ant_real, :string
  end
end
