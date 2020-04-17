module Translator
  extend self

  def fetch_translation(original, lang)
    resp = Faraday.get("https://api.deepl.com/v2/translate",
      auth_key: ENV.fetch('DEEPL_API_KEY'),
      source_lang: 'de',
      target_lang: lang,
      text: original
    )
    data = JSON.parse(resp.body)
    data.fetch('translations').first.fetch('text')
  end

  def translate_from_key(key)
    TranslationCache.with_key_cache(key, "en") do |original, lang|
      fetch_translation(original, lang)
    end
  end

  def translate(original, lang)
    TranslationCache.with_cache(original, "en") do |original, lang|
      fetch_translation(original, lang)
    end
  end

end
