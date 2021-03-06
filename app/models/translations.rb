module Translations
  class << self

    # Costs are in Euro as of 6 March 2021
    SERVICES = [
      Service.new('deepl', 'DeepL', cost_per_million: 20.0),
      Service.new('google', 'Google', cost_per_million: 16.488),
    ].freeze

    def services
      SERVICES
    end

  end
end