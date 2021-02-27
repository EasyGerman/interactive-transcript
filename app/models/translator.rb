module Translator
  extend self

  Error = Class.new(StandardError)

  def fetch_translation(original, from:, to:)
    if [from, to].all?(&DeeplTranslator.method(:language_supported?))
      [
        DeeplTranslator.translate(original, from: from, to: to),
        { cache_key: DeeplTranslator.internal_key(to) }
      ]
    else
      [
        GoogleTranslate.translate(original, from: from, to: to),
        { cache_key: GoogleTranslate.internal_key(to) }
      ]
    end
  end

  def translate_from_key(podcast, key, to:)
    TranslationCache.with_key_cache(podcast, key, possible_cache_keys(to)) do |original|
      fetch_translation(original, from: podcast.lang, to: to)
    end
  end

  def translate_with_cache(podcast, original, to:)
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

  def supported_target_languages_for(from_lang)
    from_lang = from_lang.split('-').first
    services_that_support_language_as_source(from_lang)
      .flat_map do |service|
        service::LANGUAGES_IN_COMMMON_FORMAT.reject { |item| item.language_code == from_lang }
      end
      .select(&:enabled?)
      .sort_by(&:display_name)
      .uniq(&:display_name)
  end

  def supported_target_languages_for_select(from_lang)
    from_lang = from_lang.split('-').first
    services_that_support_language_as_source(from_lang)
      .flat_map do |service|
        service::LANGUAGES_IN_COMMMON_FORMAT.reject { |item| item.language_code == from_lang }
      end
      .select(&:enabled?)
      .uniq(&:display_name)
      .sort_by(&:display_name)
      .map(&:for_select)
  end

  def services_that_support_language_as_source(lang)
    lang = lang.split('-').first
    [DeeplTranslator, GoogleTranslate].select { |service|
      service::SUPPORTED_LANGUAGES.include?(lang)
    }
  end

  def service_for(service_code)
    case service_code
    when 'google' then GoogleTranslate
    when 'deepl' then DeeplTranslator
    else raise "Unknown translation service: #{service.inspect}"
    end
  end

  def possible_cache_keys(lang)
    [DeeplTranslator, GoogleTranslate].map do |service|
      service.internal_key(lang) if service.normalized_lang(lang).present?
    end
  end
end
