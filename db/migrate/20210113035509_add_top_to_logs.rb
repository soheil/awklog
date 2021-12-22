class AddTopToLogs < ActiveRecord::Migration[6.0]
  def change
    add_column :logs, :top, :text
  end
end
