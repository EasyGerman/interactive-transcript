class Feed
  extend Memoist

  def initialize(fetcher = default_fetcher)
    @fetcher = fetcher
  end

  def default_fetcher
    if Rails.env.development? || Rails.env.test?
      DevelopmentFetcher.new
    else
      NetworkFetcher.new
    end
  end

  memoize def content
    @fetcher.fetch_feed
  end

  memoize def node
    Nokogiri::XML(content)
  end

  memoize def episodes
    node.css('item').map do |episode_node|
      Episode.new(@fetcher, episode_node, self)
    end
  end

  def cover_url
    node.css('image > url').text
  end
end
