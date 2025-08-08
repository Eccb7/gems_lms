class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.text :objectives
      t.text :prerequisites
      t.decimal :price, precision: 10, scale: 2, default: 0.0, null: false
      t.integer :status, default: 0, null: false
      t.references :instructor, null: false, foreign_key: { to_table: :users }
      t.references :category, null: false, foreign_key: true
      t.boolean :featured, default: false
      t.datetime :published_at
      t.integer :duration_minutes, default: 0
      t.integer :difficulty_level, default: 0

      t.timestamps
    end

    add_index :courses, :featured
    add_index :courses, :status
    add_index :courses, :difficulty_level
    add_index :courses, :published_at
    add_index :courses, [ :instructor_id, :status ]
    add_index :courses, [ :category_id, :status ]
  end
end
