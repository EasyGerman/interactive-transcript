class TranslationCache < ApplicationRecord

  belongs_to :podcast

  # Add a record based on the original text if it doesn't exist yet
  def self.add_original_nx(podcast_id, original)
    find_or_create_by!(podcast_id: podcast_id, key: digest(original)) do |record|
      record.original = original
    end
  end

  def self.lookup(podcast_id, original)
    find_by(podcast_id: podcast_id, key: digest(original))
  end

  def self.digest(text)
    Digest::SHA1.hexdigest(text)
  end

  def add_translation(lang, translation)
    translations[lang] = translation
  end

  def get_translation(lang)
    translations[lang]
  end

  def self.with_key_cache(podcast_id, key, lang, &block)
    find_by!(podcast_id: podcast_id, key: key).with_this_cache(lang, &block)
  end

  def self.with_cache(podcast_id, original, lang, &block)
    add_original_nx(podcast_id, original).with_this_cache(lang, &block)
  end

  def with_this_cache(lang)
    get_translation(lang) ||
      begin
        result = yield(original, lang)
        add_translation(lang, result)
        save!
        result
      end
  end

end
