class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name
      t.text :description
      t.string :color
      t.boolean :active

      t.timestamps
    end
    add_index :categories, :active
  end
end
