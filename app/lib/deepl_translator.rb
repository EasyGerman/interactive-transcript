class DeeplTranslator
  extend Memoist

  class << self
    def service_name
      'DeepL'
    end

    def service_code
      'deepl'
    end
  end


  def initialize(credentials:)
    @credentials = credentials
  end

  LANGUAGES = {
    "BG" => "Bulgarian",
    "CS" => "Czech",
    "DA" => "Danish",
    "DE" => "German",
    "EL" => "Greek",
    "EN" => "English",
    "ES" => "Spanish",
    "ET" => "Estonian",
    "FI" => "Finnish",
    "FR" => "French",
    "HU" => "Hungarian",
    "IT" => "Italian",
    "JA" => "Japanese",
    "LV" => "Latvian",
    "NL" => "Dutch",
    "PL" => "Polish",
    "PT-PT" => "Portuguese",
    # "PT-BR" => "Portuguese (Brazilian)",
    "RO" => "Romanian",
    "RU" => "Russian",
    "SK" => "Slovak",
    "SL" => "Slovenian",
    "SV" => "Swedish",
    "ZH" => "Chinese",
  }

  LANGUAGES_IN_COMMMON_FORMAT = LANGUAGES.map { |key, name|
    LanguageSupport.new(
      service: self,
      key: key,
      name: name,
      available_as_source: true,
      available_as_target: true,
    )
  }

  SUPPORTED_LANGUAGES = Set.new(LANGUAGES.map { |key, _| key.split('-')[0].downcase }.uniq)

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

  def translate(original, from:, to:)
    resp = Faraday.get("https://api.deepl.com/v2/translate",
      auth_key: ENV.fetch('DEEPL_API_KEY'),
      source_lang: coerce_lang(from),
      target_lang: coerce_lang(to),
      text: original,
      preserve_formatting: 1,

    )
    if resp.status.to_s[0] != '2'
      message = "DeepL returned: #{[resp.status, STATUS_CODE_MEANINGS[resp.status], resp.body].reject(&:blank?).join(' - ')}"
      Rails.logger.error(message)
      raise Translator::Error, message
    end
    data = JSON.parse(resp.body)
    data.fetch('translations').first.fetch('text')
  end

  def language_supported?(lang)
    normalized_lang(lang).present?
  end

  def normalized_lang(lang)
    lang = lang.upcase
    lang = "PT-PT" if lang == "PT"
    lang if LANGUAGES.key?(lang)
  end

  def coerce_lang(lang)
    normalized_lang(lang) ||
      raise(Translator::Error.new("DeepL doesn't support this language: #{lang}"))
  end

  def internal_key(lang)
    coerce_lang(lang)
  end
end
