class DevelopmentFetcher

  extend Memoist

  attr_reader :podcast

  def initialize(podcast)
    @podcast = podcast || raise(ArgumentError, 'podcast missing')
    @fs_fetcher = FsFetcher.new
  end

  def fetch_feed
    with_local_cache(fs_fetcher.path_to_feed) do
      network_fetcher.fetch_feed
    end
  end

  def fetch_downloadable_transcript(episode)
    with_local_cache(fs_fetcher.path_to_downloadable_transcript(episode)) do
      network_fetcher.fetch_downloadable_transcript(episode)
    end
  end

  def fetch_editor_transcript(episode)
    with_local_cache(fs_fetcher.path_to_editor_transcript(episode)) do
      network_fetcher.fetch_editor_transcript(episode)
    end
  end

  private

  attr_reader :fs_fetcher

  def with_local_cache(path)
    return File.read(path) if File.exists?(path)

    yield.tap do |content|
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, "w") { |f| f.write(content) }
    end
  end

  memoize def network_fetcher
    NetworkFetcher.new(podcast)
  end

end
