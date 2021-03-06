class Translation < ApplicationRecord

  belongs_to :translation_cache # represents a paragraph

  VALID_SERVICES = %w[deepl google]

  validates :lang, inclusion: { in: Translator::VALID_LANGUAGES }
  validates :source_lang, inclusion: { in: Translator::VALID_LANGUAGES }
  validates :region, length: { is: 2 }, format: { with: /\A[A-Z]{2}\Z/ }, allow_nil: true
  validates :translation_service, inclusion: { in: VALID_SERVICES }

end