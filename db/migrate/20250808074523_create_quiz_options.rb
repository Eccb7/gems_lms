class CreateQuizOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :quiz_options do |t|
      t.references :quiz_question, null: false, foreign_key: true
      t.string :option_text
      t.boolean :is_correct
      t.integer :position

      t.timestamps
    end
  end
end
