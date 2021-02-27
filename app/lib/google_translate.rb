module GoogleTranslate
  extend self
  extend Memoist

  LANGUAGES = {
    "af" => { name: "Afrikaans", source: true, target: true },
    "am" => { name: "Amharic", source: true, target: true },
    "ar" => { name: "Arabic", source: true, target: true },
    "az" => { name: "Azerbaijani", source: true, target: true },
    "be" => { name: "Belarusian", source: true, target: true },
    "bg" => { name: "Bulgarian", source: true, target: true },
    "bn" => { name: "Bengali", source: true, target: true },
    "bs" => { name: "Bosnian", source: true, target: true },
    "ca" => { name: "Catalan; Valencian", source: true, target: true },
    "ceb" => { name: "Cebuano", source: true, target: true },
    "co" => { name: "Corsican", source: true, target: true },
    "cs" => { name: "Czech", source: true, target: true },
    "cy" => { name: "Welsh", source: true, target: true },
    "da" => { name: "Danish", source: true, target: true },
    "de" => { name: "German", source: true, target: true },
    "el" => { name: "Greek", source: true, target: true },
    "en" => { name: "English", source: true, target: true },
    "eo" => { name: "Esperanto", source: true, target: true },
    "es" => { name: "Spanish", source: true, target: true },
    "et" => { name: "Estonian", source: true, target: true },
    "eu" => { name: "Basque", source: true, target: true },
    "fa" => { name: "Persian", source: true, target: true },
    "fi" => { name: "Finnish", source: true, target: true },
    "fr" => { name: "French", source: true, target: true },
    "fy" => { name: "Western Frisian", source: true, target: true },
    "ga" => { name: "Irish", source: true, target: true },
    "gd" => { name: "Gaelic", source: true, target: true },
    "gl" => { name: "Galician", source: true, target: true },
    "gu" => { name: "Gujarati", source: true, target: true },
    "ha" => { name: "Hausa", source: true, target: true },
    "haw" => { name: "Hawaiian", source: true, target: true },
    "he" => { name: "Hebrew", source: true, target: true },
    "hi" => { name: "Hindi", source: true, target: true },
    "hmn" => { name: "Hmong; Mong", source: true, target: true },
    "hr" => { name: "Croatian", source: true, target: true },
    "ht" => { name: "Haitian", source: true, target: true },
    "hu" => { name: "Hungarian", source: true, target: true },
    "hy" => { name: "Armenian", source: true, target: true },
    "id" => { name: "Indonesian", source: true, target: true },
    "ig" => { name: "Igbo", source: true, target: true },
    "is" => { name: "Icelandic", source: true, target: true },
    "it" => { name: "Italian", source: true, target: true },
    "ja" => { name: "Japanese", source: true, target: true },
    "ka" => { name: "Georgian", source: true, target: true },
    "kk" => { name: "Kazakh", source: true, target: true },
    "km" => { name: "Central Khmer", source: true, target: true },
    "kn" => { name: "Kannada", source: true, target: true },
    "ko" => { name: "Korean", source: true, target: true },
    "ku" => { name: "Kurdish", source: true, target: true },
    "ky" => { name: "Kirghiz; Kyrgyz", source: true, target: true },
    "la" => { name: "Latin", source: true, target: true },
    "lb" => { name: "Luxembourgish", source: true, target: true },
    "lo" => { name: "Lao", source: true, target: true },
    "lt" => { name: "Lithuanian", source: true, target: true },
    "lv" => { name: "Latvian", source: true, target: true },
    "mg" => { name: "Malagasy", source: true, target: true },
    "mi" => { name: "Maori", source: true, target: true },
    "mk" => { name: "Macedonian", source: true, target: true },
    "ml" => { name: "Malayalam", source: true, target: true },
    "mn" => { name: "Mongolian", source: true, target: true },
    "mr" => { name: "Marathi", source: true, target: true },
    "ms" => { name: "Malay", source: true, target: true },
    "mt" => { name: "Maltese", source: true, target: true },
    "my" => { name: "Burmese", source: true, target: true },
    "ne" => { name: "Nepali", source: true, target: true },
    "nl" => { name: "Dutch; Flemish", source: true, target: true },
    "no" => { name: "Norwegian", source: true, target: true },
    "ny" => { name: "Chichewa", source: true, target: true },
    "or" => { name: "Oriya", source: true, target: true },
    "pa" => { name: "Panjabi; Punjabi", source: true, target: true },
    "pl" => { name: "Polish", source: true, target: true },
    "ps" => { name: "Pushto; Pashto", source: true, target: true },
    "pt" => { name: "Portuguese", source: true, target: true },
    "ro" => { name: "Romanian", source: true, target: true },
    "ru" => { name: "Russian", source: true, target: true },
    "rw" => { name: "Kinyarwanda", source: true, target: true },
    "sd" => { name: "Sindhi", source: true, target: true },
    "si" => { name: "Sinhala", source: true, target: true },
    "sk" => { name: "Slovak", source: true, target: true },
    "sl" => { name: "Slovenian", source: true, target: true },
    "sm" => { name: "Samoan", source: true, target: true },
    "sn" => { name: "Shona", source: true, target: true },
    "so" => { name: "Somali", source: true, target: true },
    "sq" => { name: "Albanian", source: true, target: true },
    "sr" => { name: "Serbian", source: true, target: true },
    "st" => { name: "Sotho, Southern", source: true, target: true },
    "su" => { name: "Sundanese", source: true, target: true },
    "sv" => { name: "Swedish", source: true, target: true },
    "sw" => { name: "Swahili", source: true, target: true },
    "ta" => { name: "Tamil", source: true, target: true },
    "te" => { name: "Telugu", source: true, target: true },
    "tg" => { name: "Tajik", source: true, target: true },
    "th" => { name: "Thai", source: true, target: true },
    "tk" => { name: "Turkmen", source: true, target: true },
    "tl" => { name: "Tagalog", source: true, target: true },
    "tr" => { name: "Turkish", source: true, target: true },
    "tt" => { name: "Tatar", source: true, target: true },
    "ug" => { name: "Uighur", source: true, target: true },
    "uk" => { name: "Ukrainian", source: true, target: true },
    "ur" => { name: "Urdu", source: true, target: true },
    "uz" => { name: "Uzbek", source: true, target: true },
    "vi" => { name: "Vietnamese", source: true, target: true },
    "xh" => { name: "Xhosa", source: true, target: true },
    "yi" => { name: "Yiddish", source: true, target: true },
    "yo" => { name: "Yoruba", source: true, target: true },
    "zh" => { name: "Chinese", source: true, target: true },
    "zh-CN" => { name: "Chinese (PRC)", source: true, target: true },
    "zh-TW" => { name: "Chinese (Taiwan)", source: true, target: true },
    "zu" => { name: "Zulu", source: true, target: true },
  }

  DEPRECATED_LANGUAGE_CODES = %w[iw jw]

  def translate(text, to:, from: nil)
    contents = [text]
    target_language_code = to
    source_language_code = from

    response = client.translate_text(
      parent: parent,
      contents: contents,
      target_language_code: target_language_code,
      source_language_code: source_language_code,
    )

    response.translations.first.translated_text
  end

  def supported_languages(cached: true)
    if cached
      LANGUAGES.map { |code, details| { code: code }.merge(details) }
    else
      response = client.get_supported_languages(parent: parent)
      response.languages
        .reject { |language| language.language_code.in?(DEPRECATED_LANGUAGE_CODES) }
        .map do |language|
          {
            code: language.language_code,
            name: LANGUAGES[language.language_code]&.[](:name) || ISO_639.find_by_code(language.language_code)&.english_name,
            source: language.support_source,
            target: language.support_target,
          }
        end
    end
  end

  def supported_source_languages
    response = client.get_supported_languages(parent: parent)
    response.languages.select(&:support_source).map do |langauge|
      langauge.language_code
    end
  end

  def supported_target_languages
    response = client.get_supported_languages(parent: parent)
    response.languages.select(&:support_target).map do |langauge|
      langauge.language_code
    end
  end

  private

  def location_id
    'us-central1'
  end

  def project_id
    JSON.parse(ENV['TRANSLATE_CREDENTIALS']).fetch('project_id')
  end

  def parent
    client.location_path(project: project_id, location: location_id)
  end

  def client
    Google::Cloud::Translate.translation_service
  end

end
