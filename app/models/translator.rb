module Translator
  extend self

  Error = Class.new(StandardError)

  TARGET_LANGUAGES = {
    "DE" => "German",
    "EN" => "English",
    "FR" => "French",
    "IT" => "Italian",
    "JA" => "Japanese",
    "ES" => "Spanish",
    "NL" => "Dutch",
    "PL" => "Polish",
    "PT-PT" => "Portuguese",
    "PT-BR" => "Portuguese (Brazilian)",
    "RU" => "Russian",
    "ZH" => "Chinese",
  }.reject { |key, value| key.downcase == ENV.fetch('SOURCE_LANG', 'de').downcase }

  SOURCE_LANG = ENV.fetch('SOURCE_LANG', 'de')
  DEFAULT_TARGET_LANG = 'EN'.freeze

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
      source_lang: SOURCE_LANG,
      target_lang: coerce_lang(lang),
      text: original,
      preserve_formatting: 1,

    )
    if resp.status.to_s[0] != '2'
      message = "DeepL returned: #{[resp.status, STATUS_CODE_MEANINGS[resp.status], resp.body].reject(&:blank?).join(' - ')}"
      Rails.logger.error(message)
      raise Error, message
    end
    data = JSON.parse(resp.body)
    data.fetch('translations').first.fetch('text')
  end

  def translate_from_key(podcast_id, key, lang)
    lang = coerce_lang(lang)
    TranslationCache.with_key_cache(podcast_id, key, lang) do |original, lang|
      fetch_translation(original, lang)
    end
  end

  def translate(original, lang)
    lang = coerce_lang(lang)
    TranslationCache.with_cache(podcast_id, original, lang) do |original, lang|
      fetch_translation(original, lang)
    end
  end

  def coerce_lang(lang)
    TARGET_LANGUAGES.key?(lang) ? lang : DEFAULT_TARGET_LANG
  end

end
