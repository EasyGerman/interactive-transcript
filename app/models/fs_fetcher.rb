class FsFetcher

  attr_reader :podcast

  delegate :feed_path, :episode_dir_path_for, to: :@file_storage

  def initialize(podcast)
    @podcast = podcast
    @file_storage = FileStorage.for_podcast(podcast)
  end

  def fetch_feed
    File.read(feed_path)
  end

  def path_to_downloadable_transcript(episode)
    episode_dir_path_for(episode).join('downloadable.html')
  end

  def fetch_downloadable_transcript(episode)
    File.read(path_to_downloadable_transcript(episode))
  end

  def path_to_editor_transcript(episode)
    episode_dir_path_for(episode).join('editor.html')
  end

  def fetch_editor_transcript(episode)
    File.read(path_to_editor_transcript(episode))
  end

  # For testing only

  def fetch_processed_yaml(episode)
    File.read(episode_dir_path_for(episode).join('processed.yaml'))
  end

end
