class CreateLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :logs do |t|
      t.text :raw
      t.integer :user_id

      t.timestamps
    end
    add_index :logs, :user_id
  end
end
