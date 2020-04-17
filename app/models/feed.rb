class Feed
  extend Memoist

  memoize def content
    Rails.cache.fetch("feed", expires_in: 5.minutes) do
      get_content
    end
  end

  def get_content
    require 'open-uri'
    open(ENV.fetch('PODCAST_URL')).read
  end

  memoize def node
    Nokogiri::XML(content)
  end

  memoize def episodes
    node.css('item').map do |episode_node|
      Episode.new(episode_node)
    end
  end

end
