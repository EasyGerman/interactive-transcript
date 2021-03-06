class AddTranslations < ActiveRecord::Migration[6.0]
  def change
    create_table :translations do |t|
      t.string :key, limit: 40, null: false
      t.references :translation_cache, foreign_key: true, null: false
      t.string :source_lang, size: 3, null: false
      t.string :lang, size: 3, null: false
      t.string :region, size: 2
      t.string :translation_service, size: 6, null: false
      t.integer :source_length, null: false
      t.datetime :translated_at, index: true
      t.string :body, null: false
      t.timestamps

    end
    add_index :translations, [:key, :lang]
  end
end
