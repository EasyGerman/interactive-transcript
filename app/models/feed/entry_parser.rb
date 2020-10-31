class Feed
  class EntryParser
    extend Memoist

    def initialize(node)
      @node = node
    end

    memoize def slug
      patreon_post_url[%r{^https://www.patreon.com/posts/(.*)$}, 1] || raise("Cannot find slug in #{patreon_post_url}")
    end

    memoize def patreon_post_url
      node.css('link').text
    end

    def episode_number
      slug[/^\d+/]&.to_i
    end

    def title
      node.css('title').first.text
    end

    def description
      node.css('description').text
    end

    def audio_url
      node.css('enclosure').first["url"]
    end

    def published_at
      Time.parse(node.at_css('pubDate'))
    end

    private

    attr_reader :node

  end
end
