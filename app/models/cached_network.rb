class CachedNetwork
  class << self
    def fetch(url)
      path = Rails.root.join('data', 'network-cache', Digest::SHA1.hexdigest(url))
      return File.read(path) if File.exist?(path)
      contents = open(url).read
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'wb') { |f| f.write(contents) }
      contents
    end
  end
end
