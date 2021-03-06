# TODO: rename to Paragraph
class TranslationCache < ApplicationRecord

  belongs_to :podcast
  has_many :translation_records, class_name: :Translation

  # Add a record based on the original text if it doesn't exist yet
  def self.add_original_nx(podcast, original)
    find_or_create_by!(podcast_id: podcast.id, key: digest(original)) do |record|
      record.original = original
    end
  end

  def self.lookup(podcast, original)
    find_by(podcast_id: podcast.id, key: digest(original))
  end

  def self.lookup_translation(podcast, original, lang)
    lookup(podcast, original).translation_records.find_by(lang: lang)
  end

  def self.digest(text)
    Digest::SHA1.hexdigest(text)
  end

  def add_translation(cache_key, translated_body)
    o = CacheKey[cache_key]

    translation_records.create!(
      key: key,
      source_lang: podcast.lang,
      lang: o.lang,
      region: o.region,
      translation_service: o.service,
      source_length: original.length,
      body: translated_body,
    )

    translated_body
  end

  # Get the first translation matching one of the cache keys.
  # The cache key is a combination of the language and the translation service.
  # TODO: simplify: look up based on lang code
  def get_translation(cache_keys)
    cache_keys.each do |key|
      o = CacheKey[key]
      record = translation_records.find_by(lang: o.lang)
      return record.body if record.present?
    end
    nil
  end

  def self.with_key_cache(podcast, key, cache_keys, &block)
    find_by!(podcast_id: podcast.id, key: key).with_this_cache(cache_keys, &block)
  end

  def self.with_cache(podcast, original, cache_keys, &block)
    add_original_nx(podcast, original).with_this_cache(cache_keys, &block)
  end

  def with_this_cache(cache_keys)
    raise ArgumentError, "invalid cache_keys: #{cache_keys.inspect}" if cache_keys.any?(&:nil?)
    get_translation(cache_keys) ||
      begin
        result, meta = yield(original)
        raise "invalid meta returned from yielded block: #{meta.inspect}" if meta[:cache_key].blank?
        add_translation(meta.fetch(:cache_key), result)
        save!
        result
      end
  end

  class CacheKey

    class << self
      def [](str)
        new(str)
      end
    end

    attr_reader :str, :lang, :region, :service

    def initialize(str)
      raise ArgumentError, "invalid: str: #{str.inspect}" if str.blank?
      @str = str

      lang_with_region, @service = str.split('@')
      @lang, @region = lang_with_region.split('-')
      @lang.downcase!
      @region&.upcase!
      @service ||= 'deepl'
    end
  end
end
