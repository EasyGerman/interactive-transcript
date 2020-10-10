class Feed
  extend Memoist

  LOCAL_FILE = Rails.root.join('data', 'feed.xml')

  memoize def content
    if Rails.env.development?
      return File.read(LOCAL_FILE)
    end

    RedisMutex.with_lock("feed", block: 30, sleep: 0.5, expire: 60) do
      Rails.cache.fetch("feed", expires_in: 15.seconds) do
        content = get_content
        if Rails.env.development?
          File.open(LOCAL_FILE, "w") { |f| f.write(content) }
        end
        content
      end
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
      Episode.new(episode_node, self)
    end
  end

  def cover_url
    node.css('image > url').text
  end
end
