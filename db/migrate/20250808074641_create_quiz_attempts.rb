class CreateQuizAttempts < ActiveRecord::Migration[8.0]
  def change
    create_table :quiz_attempts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :quiz, null: false, foreign_key: true
      t.datetime :started_at
      t.datetime :submitted_at
      t.decimal :score, precision: 5, scale: 2
      t.integer :status, default: 0
      t.json :answers

      t.timestamps
    end

    add_index :quiz_attempts, [ :user_id, :quiz_id ]
    add_index :quiz_attempts, :status
  end
end
