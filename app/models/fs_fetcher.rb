class FsFetcher

  def initialize(root = Rails.root.join('data'))
    @root = root
  end

  def path_to_feed
    @root.join('feed.xml')
  end

  def fetch_feed
    File.read(path_to_feed)
  end

  def path_to_downloadable_transcript(episode)
    @root.join('episodes', episode.slug, 'downloadable.html')
  end

  def fetch_downloadable_transcript(episode)
    File.read(path_to_downloadable_transcript(episode))
  end

  def path_to_editor_transcript(episode)
    @root.join('episodes', episode.slug, 'editor.html')
  end

  def fetch_editor_transcript(episode)
    File.read(path_to_editor_transcript(episode))
  end

  # For testing only

  def fetch_processed_yaml(episode)
    File.read(@root.join('episodes', episode.slug, 'processed.yaml'))
  end

end
