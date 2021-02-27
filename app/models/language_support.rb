class LanguageSupport < CustomStruct

  ENABLED_SET = Set.new(ENV.fetch('ENABLED_TRANSLATION_LANGUAGES', 'de,en,fr,it,ja,es,nl,pl,pt,ru,zh,ca,el').split(','))

  attribute :service, Types::Any
  attribute :key, Types::String
  attribute :name, Types::String
  attribute :available_as_source, Types::Bool
  attribute :available_as_target, Types::Bool

  delegate :service_name, :service_code, to: :service

  def internal_key
    service_code == 'deepl' ? key : "#{key}@#{service_code}"
  end

  def language_code
    key.split('-')[0].downcase
  end

  def region_code
    key.split('-')[1]&.upcase
  end

  def for_select
    # upcase'ing so that it's compatible with the value stored in localStorage
    [display_name, language_with_region_code.upcase, { "data-service" => service_name }]
  end

  def language_with_region_code
    [language_code, region_code].compact.join('-')
  end

  def display_name
    name
  end

  def enabled?
    ENABLED_SET.include?('all') || ENABLED_SET.include?(language_code)
  end

end
