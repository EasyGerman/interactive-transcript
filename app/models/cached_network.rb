class CachedNetwork
  class << self
    def fetch(url)
      with_file_cache(url) do
        open(url).read
      end
    end

    def with_file_cache(identifier)
      path = Rails.root.join('tmp', 'network-cache', Digest::SHA1.hexdigest(identifier))
      return File.read(path) if File.exist?(path)
      contents = yield
      return contents if contents.nil?
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'wb') { |f| f.write(contents) }
      contents
    end
  end
end
