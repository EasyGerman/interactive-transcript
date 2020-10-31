class FsFetcher

  def initialize(root)
    @root = root
  end

  def fetch_feed
    File.read(@root.join('feed.xml'))
  end

  def fetch_downloadable_transcript(episode)
    File.read(@root.join('episodes', episode.slug, 'downloadable.html'))
  end

  def fetch_editor_transcript(episode)
    File.read(@root.join('episodes', episode.slug, 'editor.html'))
  end

  def fetch_vocab_rtf(episode)
  end

  def fetch_vocab_csv(episode)
  end


  # For testing only

  def fetch_processed_yaml(episode)
    File.read(@root.join('episodes', episode.slug, 'processed.yaml'))
  end

end
