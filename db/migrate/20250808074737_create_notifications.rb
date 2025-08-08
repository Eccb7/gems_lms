class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :message
      t.integer :notification_type
      t.boolean :read
      t.datetime :sent_at

      t.timestamps
    end
  end
end
