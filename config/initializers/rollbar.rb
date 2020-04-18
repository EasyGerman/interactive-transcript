if ENV["ROLLBAR_ACCESS_TOKEN"].present?
  Rollbar.configure do |config|
    config.access_token = ENV["ROLLBAR_ACCESS_TOKEN"]
  end
end
