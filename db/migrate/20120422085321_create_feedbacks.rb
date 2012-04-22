class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.integer :survey_id
      t.string :answer
      t.string :callerid

      t.timestamps
    end
  end
end
