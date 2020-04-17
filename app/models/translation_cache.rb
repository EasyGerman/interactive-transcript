class TranslationCache < ApplicationRecord

  # Add a record based on the original text if it doesn't exist yet
  def self.add_original_nx(original)
    find_or_create_by!(key: digest(original)) do |record|
      record.original = original
    end
  end

  def self.lookup(original)
    find_by(key: digest(original))
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

  def self.with_key_cache(key, lang, &block)
    find_by!(key: key).with_this_cache(lang, &block)
  end

  def self.with_cache(original, lang, &block)
    add_original_nx(original).with_this_cache(lang, &block)
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
