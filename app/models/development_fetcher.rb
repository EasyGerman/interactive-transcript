class DevelopmentFetcher

  extend Memoist

  attr_reader :podcast

  def initialize(podcast)
    @podcast = podcast || raise(ArgumentError, 'podcast missing')
    @fs_fetcher = FsFetcher.new(podcast)
  end

  def fetch_feed
    with_local_cache(fs_fetcher.feed_path) do
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

  def with_local_cache(path, force: false)
    if File.exists?(path) && !force
      if File.size(path) > 0
        Rails.logger.debug "Cache hit: #{path} "
        return File.read(path)
      else
        Rails.logger.debug "Cache miss: #{path} (zero length)"
      end
    else
      Rails.logger.debug "Cache miss: #{path}"
    end

    yield.tap do |content|
      if content.present?
        Rails.logger.debug "Encoding of content yielded to with_local_cache: #{content.encoding}"
        FileUtils.mkdir_p(File.dirname(path))
        File.open(path, "w") { |f| f.write(content) }
      end
    end
  end

  memoize def network_fetcher
    NetworkFetcher.new(podcast)
  end

end
