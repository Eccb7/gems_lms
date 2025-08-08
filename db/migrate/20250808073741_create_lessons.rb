class CreateLessons < ActiveRecord::Migration[8.0]
  def change
    create_table :lessons do |t|
      t.string :title
      t.text :content
      t.references :section, null: false, foreign_key: true
      t.integer :position
      t.integer :lesson_type
      t.integer :duration_minutes

      t.timestamps
    end
  end
end
