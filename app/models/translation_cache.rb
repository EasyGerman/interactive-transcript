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

  def self.with_key_cache(key, lang)
    record = find_by!(key: key)
    record.get_translation(lang) ||
      begin
        result = yield(record.original, lang)
        record.add_translation(lang, result)
        record.save!
        result
      end
  end
end
