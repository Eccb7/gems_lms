class CreateSections < ActiveRecord::Migration[8.0]
  def change
    create_table :sections do |t|
      t.string :title
      t.text :description
      t.references :course, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
