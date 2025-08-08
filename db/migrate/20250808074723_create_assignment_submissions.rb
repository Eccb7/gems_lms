class CreateAssignmentSubmissions < ActiveRecord::Migration[8.0]
  def change
    create_table :assignment_submissions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :assignment, null: false, foreign_key: true
      t.text :content
      t.datetime :submitted_at
      t.decimal :grade
      t.text :feedback
      t.integer :status

      t.timestamps
    end
  end
end
