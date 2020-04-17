class CreateTranslationCaches < ActiveRecord::Migration[6.0]
  def change
    create_table :translation_caches do |t|
      t.string :key, null: false, limit: 40, index: true
      t.text :original, null: false
      t.json :translations, null: false, default: {}

      t.timestamps
    end
  end
end
