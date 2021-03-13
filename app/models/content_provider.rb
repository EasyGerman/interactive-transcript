class ContentProvider
  extend LocalCacheMethods

  class << self
    def root_path
      Rails.root.join('data')
    end

    def for_podcast(podcast)
      ::ContentProvider::ForPodcast.new(podcast, parent_path: root_path)
    end

    def for_each_podcast
      ::Podcast.all.each do |podcast|
        yield for_podcast(podcast)
      end
    end

    def import_podcasts_from_files
      Dir[podcasts_dir_path.join('*/config.yml')].each do |config_file_path|
        config = YAML.load_file(config_file_path)
        begin
          podcast = Podcast.create!(config)
          Rails.logger.info "Podcast #{podcast.code} imported"
        rescue ActiveRecord::RecordNotUnique
          podcast = Podcast.find_by!(code: config.fetch('code'))
          podcast.attributes = config
          if podcast.changed?
            podcast.save!
            Rails.logger.info "Podcast #{podcast.code} updated"
          else
            Rails.logger.info "Podcast #{podcast.code} unchanged"
          end
        end
      end
    end
  end

end
