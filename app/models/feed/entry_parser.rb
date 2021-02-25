class Feed
  class EntryParser
    extend Memoist

    def initialize(podcast, node)
      @podcast = podcast
      @node = node
    end

    memoize def slug
      # TODO: remove hardcoded easygreek
      case podcast.code
      when 'easycatalan'
        link_url[%r{easycatalan\.fm/(\d+)$}, 1]
      else
        link_url[%r{^https://www.patreon.com/posts/(.*)$}, 1] ||
          ('trailer' if link_url == 'https://www.easygreek.fm/trailer') ||
          link_url[%r{/episodes/(\d+)}, 1]
      end ||
        raise("Cannot find slug in #{link_url}")
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
      if @podcast.code == 'easycatalan'
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
