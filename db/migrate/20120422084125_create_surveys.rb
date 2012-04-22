class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.integer :product_id
      t.string :question
      t.boolean :yes_no

      t.timestamps
    end
  end
end
