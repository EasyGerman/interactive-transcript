class TranslationStats
  TIMESTAMP_COLUMN = 'translations.translated_at'
  # TIMESTAMP_COLUMN = 'translations.created_at'
  # TIMESTAMP_COLUMN = 'translation_caches.created_at'

  class << self

    def podcast_stats
      podcasts_by_id = Podcast.all.index_by(&:id)
      @stats = {}

      Translation.joins(:translation_cache)
        .group("podcast_id, lang, translation_service, to_char(#{TIMESTAMP_COLUMN}, \'YYYY-MM\')")
        .pluck("podcast_id, lang, translation_service, to_char(#{TIMESTAMP_COLUMN}, \'YYYY-MM\') as month, count(*) as total_count, sum(source_length) AS total_length")
        .each do |podcast_id, lang, service, month, count, length|
          @stats[podcast_id] ||= PodcastStats.new(podcasts_by_id.fetch(podcast_id))
          @stats[podcast_id].add_stat(month, service, lang, count, length)
        end

      @stats.values
    end
  end

  class PodcastStats
    attr_reader :podcast

    def initialize(podcast)
      @podcast = podcast
      @stats = {}
    end

    def add_stat(month, service, lang, count, length)
      @stats[month] ||= {}
      s = @stats[month][service] ||= ServiceMonthStats.new(service, month)
      s.add_stat(lang, count, length)
    end

    def service_month_stats(service, month)
      @stats.dig(month, service)
    end

    def total_length_for_month(month)
      (@stats[month]&.values || []).map(&:total_length).sum
    end

    def total_count_for_month(month)
      (@stats[month]&.values || []).map(&:total_count).sum
    end
  end

  class ServiceMonthStats
    attr_reader :service, :month

    COST_PER_MILLION = {
      'google' => 16.488,
      'deepl' => 20.0,
    }

    def initialize(service, month)
      @service = service
      @month = month
      @stats = {}
    end

    def add_stat(lang, count, length)
      @stats[lang] = Struct.new(:lang, :count, :length).new(lang, count, length)
    end

    def lang_stats
      @stats.values.sort_by { |lang_stats| -lang_stats.length }
    end

    def total_length
      @stats.values.map(&:length).sum
    end

    def total_count
      @stats.values.map(&:count).sum
    end

    def total_cost
      (COST_PER_MILLION.fetch(service) * total_length / 1_000_000).round(2)
    end

  end
end