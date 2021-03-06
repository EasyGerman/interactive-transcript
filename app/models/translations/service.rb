module Translations
  class Service
    attr_reader :code, :name, :cost_per_million

    def initialize(code, name, cost_per_million:)
      @code = code
      @name = name
      @cost_per_million = cost_per_million
    end

    def cost_for_characters(character_count)
      (character_count.to_f * cost_per_million / 1_000_000).round(2)
    end
  end
end