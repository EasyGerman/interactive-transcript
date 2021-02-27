class TranslationCache < ApplicationRecord

  belongs_to :podcast

  # Add a record based on the original text if it doesn't exist yet
  def self.add_original_nx(podcast, original)
    find_or_create_by!(podcast_id: podcast.id, key: digest(original)) do |record|
      record.original = original
    end
  end

  def self.lookup(podcast, original)
    find_by(podcast_id: podcast.id, key: digest(original))
  end

  def self.digest(text)
    Digest::SHA1.hexdigest(text)
  end

  def add_translation(cache_key, translation)
    translations[cache_key] = translation
  end

  def get_translation(cache_keys)
    cache_keys.each do |key|
      return translations[key] if translations.key?(key)
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
    get_translation(cache_keys) ||
      begin
        result, meta = yield(original)
        add_translation(meta.fetch(:cache_key), result)
        save!
        result
      end
  end

end
