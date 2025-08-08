class CreateAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :assignments do |t|
      t.string :title
      t.text :description
      t.references :lesson, null: false, foreign_key: true
      t.datetime :due_date
      t.decimal :max_points
      t.integer :submission_format

      t.timestamps
    end
  end
end
