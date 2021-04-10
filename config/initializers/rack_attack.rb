# To test in development, set the cache_store in development.rb to redis, e.g:
#     config.cache_store = :redis_cache_store, { url: ENV.fetch('REDIS_URL') }

class Rack::Attack
  {
    second: { limit: 1, period: 1.second },
    minute: { limit: 12, period: 1.minute },
    hour:   { limit: 60, period: 1.hour },
    day:    { limit: 100, period: 1.day },
    week:   { limit: 300, period: 1.week },
  }.each do |key, options|
    throttle("translations/ip24/#{key}", options) do |req|
      if req.path =~ %r{^/translate.*$} && req.post? && req.params["from_cache"] != "true"
        req.ip.split('.').first(3).join('.')
      end
    end
  end

  self.throttled_response = lambda do |env|
    match_data = env['rack.attack.match_data']

    req = Rack::Request.new(env)
    Rails.logger.info "RequestThrottled ip=#{req.ip} #{match_data.map { |k, v| "#{k}=#{v}" }.join(' ') }"
    [503, {'Content-Type' => 'application/json'}, [{ error: { message: "Too many requests" }}.to_json]]
  end
end
