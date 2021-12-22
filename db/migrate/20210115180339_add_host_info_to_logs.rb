class AddHostInfoToLogs < ActiveRecord::Migration[6.0]
  def change
    add_column :logs, :host_ip, :string
    add_column :logs, :hostname, :string
  end
end
