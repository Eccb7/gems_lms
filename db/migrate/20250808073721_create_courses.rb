class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.string :title
      t.text :description
      t.text :objectives
      t.text :prerequisites
      t.decimal :price
      t.integer :status
      t.references :instructor, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.boolean :featured
      t.datetime :published_at
      t.integer :duration_minutes
      t.integer :difficulty_level

      t.timestamps
    end
    add_index :courses, :featured
  end
end
