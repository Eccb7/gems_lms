class CreateQuizzes < ActiveRecord::Migration[8.0]
  def change
    create_table :quizzes do |t|
      t.string :title
      t.text :description
      t.references :lesson, null: false, foreign_key: true
      t.integer :time_limit_minutes
      t.integer :max_attempts
      t.decimal :passing_score

      t.timestamps
    end
  end
end
