class DevelopmentFetcher

  def initialize
    @fs_fetcher = FsFetcher.new
    @network_fetcher = NetworkFetcher
  end

  def fetch_feed
    # with_local_cache(fs_fetcher.path_to_feed) do
      NetworkFetcher.new.fetch_feed
    # end
  end

  def fetch_downloadable_transcript(episode)
    with_local_cache(fs_fetcher.path_to_downloadable_transcript(episode)) do
      NetworkFetcher.new.fetch_downloadable_transcript(episode)
    end
  end

  def fetch_editor_transcript(episode)
    with_local_cache(fs_fetcher.path_to_editor_transcript(episode)) do
      NetworkFetcher.new.fetch_editor_transcript(episode)
    end
  end

  private

  attr_reader :fs_fetcher, :network_fetcher

  def with_local_cache(path)
    return File.read(path) if File.exists?(path)

    yield.tap do |content|
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, "w") { |f| f.write(content) }
    end
  end

end
