class ContentProvider
  module LocalCacheMethods
    def with_local_cache(path, force: false)
      return yield unless Rails.env.development? || Rails.env.test?

      if File.exists?(path) && !force
        if File.size(path) > 0
          if File.mtime(path) < 1.hour.ago
            Rails.logger.debug "Cache old: #{path} "
          else
            Rails.logger.debug "Cache hit: #{path} "
            return File.read(path)
          end
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
          File.open(path, "wb") { |f| f.write(content) }
        end
      end
    end

    def root_path
      Rails.root.join('data')
    end

    def podcasts_dir_path
      root_path.join('podcasts')
    end

  end
end
