class NetworkFetcher

  def fetch_feed(podcast)
    RedisMutex.with_lock("feed:#{podcast.code}", block: 30, sleep: 0.5, expire: 60) do
      Rails.cache.fetch("feed:#{podcast.code}", expires_in: 15.seconds) do
        require 'open-uri'
        open(podcast.feed_url).read
      end
    end
  end

  def fetch_downloadable_transcript(episode)
    URI.open(episode.downloadable_html_url).read
  end

  def fetch_editor_transcript(episode)
    editor_transcript_config = episode.podcast.editor_transcript_config

    file_contents =
      DropboxAdapter.new(
        editor_transcript_config["dropbox_access_key"],
        editor_transcript_config["dropbox_shared_link"],
      ).transcript_for(episode.number)

    doc = Nokogiri::HTML(file_contents)
    doc.css('#transcript').to_html
  end

end
