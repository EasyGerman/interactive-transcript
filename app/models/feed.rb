class Feed
  extend Memoist

  LOCAL_FILE = Rails.root.join('data', 'feed.xml')

  memoize def content
    if Rails.env.development?
      return File.read(LOCAL_FILE)
    end

    Rails.cache.fetch("feed", expires_in: 5.minutes) do
      content = get_content
      if Rails.env.development?
        File.open(LOCAL_FILE, "w") { |f| f.write(content) }
      end
      content
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

  def cover_url
    node.css('image > url').text
  end
end
