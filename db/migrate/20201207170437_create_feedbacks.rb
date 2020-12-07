class CreateFeedbacks < ActiveRecord::Migration[6.0]
  def change
    create_table :feedbacks do |t|
      t.boolean :outcome, null: false
      t.timestamps
    end
  end
end
