class Feed
  extend Memoist

  attr_reader :podcast

  def initialize(podcast, fetcher = nil)
    @podcast = podcast || raise(ArgumentError, 'podcast missing')
    @fetcher = fetcher || default_fetcher
  end

  def default_fetcher
    ContentProvider.for_podcast(podcast)
  end

  memoize def content
    @fetcher.fetch_feed
  end

  memoize def node
    Nokogiri::XML(content)
  end

  memoize def episodes
    node.css('item').map do |episode_node|
      Episode.new(@podcast, @fetcher, episode_node, self)
    end
  end

  def cover_url
    node.css('image > url').text
  end

  def generator
    node.css('generator').text
  end
end
