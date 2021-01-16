class DropboxAdapter
  def initialize(access_key, shared_link)
    @access_key = access_key
    @shared_link = shared_link
  end

  def transcript_for(episode_number)
    if [@access_key, @shared_link].any?(&:blank?)
      Rails.logger.warn("@access_key missing") if @access_key.blank?
      Rails.logger.warn("@shared_link missing") if @shared_link.blank?
      return
    end
    get_shared_link_file("/#{episode_number}.html")
  end

  def get_shared_link_file(path)
    CachedNetwork.with_file_cache("Drobpox:#{@shared_link}:#{path}") do
      response = Faraday.post("https://content.dropboxapi.com/2/sharing/get_shared_link_file") do |req|
        req.headers["Authorization"] = "Bearer #{@access_key}"
        req.headers["Content-Type"] = "application/octet-stream"
        req.headers["Dropbox-API-Arg"] = JSON.generate(url: @shared_link, path: path)
      end
      case response.status
      when 200 then response.body.force_encoding("UTF-8")
      when 404, 409 then nil
      else raise "Dropbox returned #{response.status} #{response.body} for #{@shared_link.inspect} #{path.inspect}"
      end
    end
  end
end
