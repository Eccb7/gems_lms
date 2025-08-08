class CreateEnrollments < ActiveRecord::Migration[8.0]
  def change
    create_table :enrollments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.datetime :enrolled_at, null: false
      t.datetime :completed_at
      t.decimal :progress_percentage, precision: 5, scale: 2, default: 0.0
      t.integer :status, default: 0

      t.timestamps
    end

    add_index :enrollments, [ :user_id, :course_id ], unique: true
    add_index :enrollments, :status
    add_index :enrollments, :enrolled_at
  end
end
