class ContentProvider
  class ForPodcast
    include ::ContentProvider::LocalCacheMethods

    attr_reader :podcast, :parent_path

    def initialize(podcast, parent_path:)
      @podcast = podcast
      @parent_path = parent_path
    end

    def for_episode(episode)
      ForEpisode.new(episode, parent_path: root_path)
    end

    def root_path
      parent_path.join('podcasts', podcast.code)
    end

    # ---------- feed ----------

    def feed_path
      root_path.join('feed.xml')
    end

    def fetch_feed(force: false)
      with_local_cache(feed_path, force: false) do
        RedisMutex.with_lock("feed:#{podcast.code}", block: 30, sleep: 0.5, expire: 60) do
          Rails.cache.fetch("feed:#{podcast.code}", expires_in: 15.seconds) do
            NetworkUtils.get_utf8(podcast.feed_url)
          end
        end
      end
    end

    # ---------- config file ----------

    def write_config(data)
      write_file(config_file_path, YAML.dump(data))
      Rails.logger.info "Written podcast config to #{config_file_path.relative_path_from(Rails.root)}"
    end

    def read_config
      YAML.load_file(config_file_path)
    end

    def config_file_path
      root_path.join('config.yml')
    end

    # ---------- file utils ----------

    def write_file(path, content)
      path = root_path.join(path) if path.is_a?(String)
      FileUtils.mkdir_p(path.join('..'))
      File.open(path, 'w') { |f| f.write(content) }
    end

  end
end
