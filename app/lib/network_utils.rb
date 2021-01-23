module NetworkUtils
  module_function

  def get_utf8(url)
    Rails.logger.info("Fetching #{url}")
    require 'open-uri'

    open(url) do |io|
      io.set_encoding('UTF-8')
      io.read
    end
  end

  def get(url)
    Rails.logger.info("Fetching #{url}")
    require 'open-uri'

    open(url) do |io|
      io.read
    end
  end
end
