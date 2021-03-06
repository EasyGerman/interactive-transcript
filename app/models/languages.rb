module Languages
  LANGUAGES = {
    "af" => { name: "Afrikaans" },
    "am" => { name: "Amharic" },
    "ar" => { name: "Arabic" },
    "az" => { name: "Azerbaijani" },
    "be" => { name: "Belarusian" },
    "bg" => { name: "Bulgarian" },
    "bn" => { name: "Bengali" },
    "bs" => { name: "Bosnian" },
    "ca" => { name: "Catalan" },
    "ceb" => { name: "Cebuano" },
    "co" => { name: "Corsican" },
    "cs" => { name: "Czech" },
    "cy" => { name: "Welsh" },
    "da" => { name: "Danish" },
    "de" => { name: "German" },
    "el" => { name: "Greek" },
    "en" => { name: "English" },
    "eo" => { name: "Esperanto" },
    "es" => { name: "Spanish" },
    "et" => { name: "Estonian" },
    "eu" => { name: "Basque" },
    "fa" => { name: "Persian" },
    "fi" => { name: "Finnish" },
    "fr" => { name: "French" },
    "fy" => { name: "Western Frisian" },
    "ga" => { name: "Irish" },
    "gd" => { name: "Gaelic" },
    "gl" => { name: "Galician" },
    "gu" => { name: "Gujarati" },
    "ha" => { name: "Hausa" },
    "haw" => { name: "Hawaiian" },
    "he" => { name: "Hebrew" },
    "hi" => { name: "Hindi" },
    "hmn" => { name: "Hmong; Mong" },
    "hr" => { name: "Croatian" },
    "ht" => { name: "Haitian" },
    "hu" => { name: "Hungarian" },
    "hy" => { name: "Armenian" },
    "id" => { name: "Indonesian" },
    "ig" => { name: "Igbo" },
    "is" => { name: "Icelandic" },
    "it" => { name: "Italian" },
    "ja" => { name: "Japanese" },
    "ka" => { name: "Georgian" },
    "kk" => { name: "Kazakh" },
    "km" => { name: "Central Khmer" },
    "kn" => { name: "Kannada" },
    "ko" => { name: "Korean" },
    "ku" => { name: "Kurdish" },
    "ky" => { name: "Kirghiz" },
    "la" => { name: "Latin" },
    "lb" => { name: "Luxembourgish" },
    "lo" => { name: "Lao" },
    "lt" => { name: "Lithuanian" },
    "lv" => { name: "Latvian" },
    "mg" => { name: "Malagasy" },
    "mi" => { name: "Maori" },
    "mk" => { name: "Macedonian" },
    "ml" => { name: "Malayalam" },
    "mn" => { name: "Mongolian" },
    "mr" => { name: "Marathi" },
    "ms" => { name: "Malay" },
    "mt" => { name: "Maltese" },
    "my" => { name: "Burmese" },
    "ne" => { name: "Nepali" },
    "nl" => { name: "Dutch" },
    "no" => { name: "Norwegian" },
    "ny" => { name: "Chichewa" },
    "or" => { name: "Oriya" },
    "pa" => { name: "Panjabi" },
    "pl" => { name: "Polish" },
    "ps" => { name: "Pushto" },
    "pt" => { name: "Portuguese" },
    "ro" => { name: "Romanian" },
    "ru" => { name: "Russian" },
    "rw" => { name: "Kinyarwanda" },
    "sd" => { name: "Sindhi" },
    "si" => { name: "Sinhala" },
    "sk" => { name: "Slovak" },
    "sl" => { name: "Slovenian" },
    "sm" => { name: "Samoan" },
    "sn" => { name: "Shona" },
    "so" => { name: "Somali" },
    "sq" => { name: "Albanian" },
    "sr" => { name: "Serbian" },
    "st" => { name: "Sotho" },
    "su" => { name: "Sundanese" },
    "sv" => { name: "Swedish" },
    "sw" => { name: "Swahili" },
    "ta" => { name: "Tamil" },
    "te" => { name: "Telugu" },
    "tg" => { name: "Tajik" },
    "th" => { name: "Thai" },
    "tk" => { name: "Turkmen" },
    "tl" => { name: "Tagalog" },
    "tr" => { name: "Turkish" },
    "tt" => { name: "Tatar" },
    "ug" => { name: "Uighur" },
    "uk" => { name: "Ukrainian" },
    "ur" => { name: "Urdu" },
    "uz" => { name: "Uzbek" },
    "vi" => { name: "Vietnamese" },
    "xh" => { name: "Xhosa" },
    "yi" => { name: "Yiddish" },
    "yo" => { name: "Yoruba" },
    "zh" => { name: "Chinese" },
    "zu" => { name: "Zulu" },
  }

  class << self
    def [](lang)
      Language.new({ code: lang }.merge(LANGUAGES.fetch(lang)))
    end
  end

end