class CreateCourseProgresses < ActiveRecord::Migration[8.0]
  def change
    create_table :course_progresses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.boolean :completed
      t.datetime :completed_at
      t.decimal :progress_percentage
      t.datetime :last_accessed_at

      t.timestamps
    end
  end
end
