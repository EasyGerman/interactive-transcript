module Translator
  extend self

  Error = Class.new(StandardError)

  STATUS_CODE_MEANINGS = {
    400 => 'Bad request. Please check error message and your parameters.',
    403 => 'Authorization failed. Please supply a valid auth_key parameter.',
    404 => 'The requested resource could not be found.',
    413 => 'The request size exceeds the limit.',
    429 => 'Too many requests. Please wait and resend your request.',
    456 => 'Quota exceeded. The character limit has been reached.',
    500 => 'Internal error',
    503 => 'Resource currently unavailable. Try again later.',
  }

  def fetch_translation(original, lang)
    resp = Faraday.get("https://api.deepl.com/v2/translate",
      auth_key: ENV.fetch('DEEPL_API_KEY'),
      source_lang: 'de',
      target_lang: lang,
      text: original
    )
    if resp.status.to_s[0] != '2'
      raise Error, "DeepL returned: #{[resp.status, STATUS_CODE_MEANINGS[resp.status], resp.body].reject(&:blank?).join(' - ')}"
    end
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
