class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.string :provider
      t.datetime :last_active_at
      t.boolean :has_card_on_file
      t.string :plan
      t.string :uid
      t.string :image
      t.boolean :cancelled
      t.string :company
      t.string :phone
      t.string :google_token
      t.string :google_refresh_token
      t.text :push_subscription

      t.timestamps
    end
  end
end
