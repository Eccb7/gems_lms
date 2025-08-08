class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.text :description
      t.string :color
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :categories, :active
    add_index :categories, :name, unique: true
  end
end
