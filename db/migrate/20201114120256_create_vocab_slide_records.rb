class CreateVocabSlideRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :vocab_slide_records do |t|
      t.references :episode_record, foreign_key: true, null: false, index: false
      t.string :chapter_key, limit: 10, null: false
      t.binary :data
      t.datetime :uploaded_at
    end

    add_index :vocab_slide_records, [:episode_record_id, :chapter_key], unique: true
  end
end
