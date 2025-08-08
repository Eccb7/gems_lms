class AddIndexesToAssignmentSubmissions < ActiveRecord::Migration[8.0]
  def change
    add_index :assignment_submissions, [ :user_id, :assignment_id ], unique: true
    add_index :assignment_submissions, :status
    add_index :assignment_submissions, :submitted_at

    # Add default values for status and feedback
    change_column_default :assignment_submissions, :status, 0
  end
end
