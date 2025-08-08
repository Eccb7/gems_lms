class CreateQuizQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :quiz_questions do |t|
      t.references :quiz, null: false, foreign_key: true
      t.text :question_text
      t.integer :question_type
      t.integer :position
      t.decimal :points

      t.timestamps
    end
  end
end
