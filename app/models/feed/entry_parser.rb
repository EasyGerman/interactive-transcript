class Feed
  class EntryParser
    extend Memoist

    def initialize(podcast, feed, node)
      @podcast = podcast
      @feed = feed
      @node = node
    end

    # DEPRECATED in favor of episode.short_name
    memoize def slug
      # TODO: remove hardcoded easygreek/easycatalan
      case podcast.code
      when 'easycatalan'
        link_url[%r{easycatalan\.fm/(\d+)$}, 1] || link_url[%r{https://shows.acast.com/easycatalan/episodes/(\d+)}, 1]
      else
        link_url[%r{^https://www.patreon.com/posts/(.*)$}, 1] ||
          ('trailer' if link_url == 'https://www.easygreek.fm/trailer' || link_url == 'https://shows.acast.com/easyeaspanish/episodes/trailer') ||
          link_url[%r{/episodes/(\d+)}, 1]
      end ||
        episode_id ||
        raise("Cannot find slug in #{link_url}")
    end

    memoize def episode_id
      node.xpath('acast:episodeId').text.strip.presence
    rescue StandardError => error
      Rails.logger.warn('No episode id found')
      nil
    end

    memoize def link_url
      node.css('link').text
    end

    # DEPRECATED in favor of episode.short_name
    def episode_number
      return 0 if link_url == 'https://shows.acast.com/easyeaspanish/episodes/trailer'
      if podcast.code == 'easygreek'
        link_url[%r{/episodes/(\d+)}, 1]&.to_i
      else
        slug[/^\d+/]&.to_i
      end
    end

    def title
      node.css('title').first.text.strip
    end

    def description
      if @feed.generator&.start_with?('Fireside')
        node.xpath('content:encoded').first.text.strip
      else
        node.css('description').text.strip
      end
    end

    def audio_url
      node.css('enclosure').first["url"]
    end

    def published_at
      Time.parse(node.at_css('pubDate'))
    end

    private

    attr_reader :node, :podcast

  end
end
