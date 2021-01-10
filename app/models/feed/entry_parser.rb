class Feed
  class EntryParser
    extend Memoist

    def initialize(podcast, node)
      @podcast = podcast
      @node = node
    end

    memoize def slug
      # TODO: remove hardcoded easygreek
      link_url[%r{^https://www.patreon.com/posts/(.*)$}, 1] ||
        ('trailer' if link_url == 'https://www.easygreek.fm/trailer') ||
        episode_number.to_s ||
        raise("Cannot find slug in #{patreon_post_url}")
    end

    memoize def link_url
      node.css('link').text
    end

    def episode_number
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
      node.css('description').text.strip
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
