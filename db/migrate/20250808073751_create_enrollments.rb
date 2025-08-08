class CreateEnrollments < ActiveRecord::Migration[8.0]
  def change
    create_table :enrollments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.datetime :enrolled_at
      t.datetime :completed_at
      t.decimal :progress_percentage
      t.integer :status

      t.timestamps
    end
  end
end
