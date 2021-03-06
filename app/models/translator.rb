class Translator

  DEFAULT_LANGUAGES = "en,ja,fr,it,es,nl,pl,pt,ru,zh"
  VALID_LANGUAGES = (DeeplTranslator::SUPPORTED_LANGUAGES + GoogleTranslate::SUPPORTED_LANGUAGES).map { |lang| lang.split('-', 2).first.downcase }

  extend Memoist

  attr_accessor :podcast, :translators, :deepl_translator, :google_translator

  def initialize(podcast)
    @podcast = podcast
    @translations_config = podcast.settings["translations"] || {}
    @services = @translations_config["services"] || {}
    @translators = []

    @deepl_translator = DeeplTranslator.new(credentials: { "api_key" => ENV.fetch("DEEPL_API_KEY") })
    @translators << @deepl_translator

    if @services["google"]
      @google_translator = GoogleTranslate.new(credentials: @services["google"]["credentials"])
      @translators << @google_translator
    end

    @enabled_languages = @translations_config.fetch("languages", DEFAULT_LANGUAGES)&.split(",")
  end

  Error = Class.new(StandardError)

  def fetch_translation(original, from:, to:)
    if [from, to].all?(&deepl_translator.method(:language_supported?))
      [
        deepl_translator.translate(original, from: from, to: to),
        { cache_key: deepl_translator.internal_key(to) }
      ]
    else
      [
        google_translator.translate(original, from: from, to: to),
        { cache_key: google_translator.internal_key(to) }
      ]
    end
  end

  def translate_from_key(key, to:)
    TranslationCache.with_key_cache(podcast, key, possible_cache_keys(to)) do |original|
      fetch_translation(original, from: podcast.lang, to: to)
    end
  end

  def translate_with_cache(original, to:)
    TranslationCache.with_cache(podcast, original, possible_cache_keys(to)) do |original|
      fetch_translation(original, from: podcast.lang, to: to)
    end
  end

  def coerce_lang(lang)
    if possible_cache_keys(lang).empty?
      raise(Translator::Error.new("We don't support this language: #{lang}"))
    end
    lang
  end

  def supported_target_languages_for_select
    from_lang = podcast.lang
    services_that_support_language_as_source(from_lang)
      .flat_map do |service|
        service.class::LANGUAGES_IN_COMMMON_FORMAT.reject { |item| item.language_code == from_lang }
      end
      .select(&method(:language_enabled?))
      .uniq(&:display_name)
      .sort_by(&:display_name)
      .map(&:for_select)
  end

  def services_that_support_language_as_source(lang)
    lang = lang.split('-').first
    translators.select { |service|
      service.class::SUPPORTED_LANGUAGES.include?(lang)
    }
  end

  def service_for(service_code)
    case service_code
    when 'deepl' then deepl_translator
    when 'google' then google_translator
    else raise "Unknown translation service: #{service_code.inspect}"
    end
  end

  def possible_cache_keys(lang)
    translators.map do |translator|
      translator.internal_key(lang) if translator.normalized_lang(lang).present?
    end
  end

  def language_enabled?(language)
    language.language_code.in?(@enabled_languages) && language.language_code != podcast.lang
  end
end
