class MigrateTranslations < ActiveRecord::Migration[6.0]
  def change
    TranslationCache.find_each do |tc|
      tc.translations.each do |lang_key, body|
        lang_with_region, service = lang_key.split('@')
        lang, region = lang_with_region.split('-')
        lang.downcase!
        region&.upcase!

        Translation.create!(
          key: tc.key,
          translation_cache_id: tc.id,
          source_lang: tc.podcast.lang,
          lang: lang,
          region: region,
          translation_service: service || 'deepl',
          source_length: tc.original.length,
          body: body,
        )
      end
    end
  end
end
