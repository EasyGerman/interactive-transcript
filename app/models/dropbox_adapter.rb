class DropboxAdapter
  ACCESS_KEY  = ENV['DROPBOX_ACCESS_KEY'].freeze
  SHARED_LINK = ENV['DROPBOX_SHARED_LINK'].freeze

  def transcript_for(episode_number)
    if [ACCESS_KEY, SHARED_LINK].any?(&:blank?)
      Rails.logger.warn("DROPBOX_ACCESS_KEY missing") if ACCESS_KEY.blank?
      Rails.logger.warn("DROPBOX_SHARED_LINK missing") if SHARED_LINK.blank?
      return
    end
    get_shared_link_file("/#{episode_number}.html")
  end

  def get_shared_link_file(path)
    CachedNetwork.with_file_cache("Drobpox:#{SHARED_LINK}:#{path}") do
      response = Faraday.post("https://content.dropboxapi.com/2/sharing/get_shared_link_file") do |req|
        req.headers["Authorization"] = "Bearer #{ACCESS_KEY}"
        req.headers["Content-Type"] = "application/octet-stream"
        req.headers["Dropbox-API-Arg"] = JSON.generate(url: SHARED_LINK, path: path)
      end
      case response.status
      when 200 then response.body
      when 404, 409 then nil
      else raise "Dropbox returned #{response.status} #{response.body} for #{SHARED_LINK.inspect} #{path.inspect}"
      end
    end
  end
end
