class FileStorage
  class << self
    def root_path
      Rails.root.join('data')
    end

    def podcasts_dir_path
      root_path.join('podcasts')
    end

    def for_podcast(podcast)
      PodcastStorage.new(podcasts_dir_path.join(podcast.code), podcast)
    end

    def each_podcast
      Dir[podcasts_dir_path.join('*')].each do |file_entry|
        if File.directory?(file_entry)
          code = File.basename(file_entry)
          yield PodcastStorage.new(podcasts_dir_path.join(code))
        end
      end
    end

  end

  class PodcastStorage

    attr_reader :path, :podcast

    def initialize(path, podcast = nil)
      @path = path
      @podcast = podcast
    end

    def write_config(data)
      write_file(config_file_path, YAML.dump(data))
      Rails.logger.info "Written podcast config to #{config_file_path.relative_path_from(Rails.root)}"
    end

    def read_config
      YAML.load_file(config_file_path)
    end

    def config_file_path
      path.join('config.yml')
    end

    def write_file(path, content)
      FileUtils.mkdir_p(path.join('..'))
      File.open(path, 'w') { |f| f.write(content) }
    end

    def feed_path
      path.join('feed.xml')
    end

    def episode_dir_path_for(episode)
      path.join('episodes', episode.slug)
    end

  end
end
