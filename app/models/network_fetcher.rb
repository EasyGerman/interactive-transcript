class NetworkFetcher

  def fetch_feed
    RedisMutex.with_lock("feed", block: 30, sleep: 0.5, expire: 60) do
      Rails.cache.fetch("feed", expires_in: 15.seconds) do
        require 'open-uri'
        open(ENV.fetch('PODCAST_URL')).read
      end
    end
  end

  def fetch_downloadable_transcript(episode)
    URI.open(episode.downloadable_html_url).read
  end

  def fetch_editor_transcript(episode)
    file_contents = DropboxAdapter.new.transcript_for(episode.number)
    doc = Nokogiri::HTML(file_contents)
    doc.css('#transcript').to_html
  end

end
