puts "RACK ATTACK"

class Rack::Attack
  {
    second: { limit: 1, period: 5.seconds },
    minute: { limit: 12, period: 1.minute },
    hour:   { limit: 60, period: 1.hour },
    day:    { limit: 100, period: 1.day },
    week:   { limit: 300, period: 1.week },
  }.each do |key, options|
    throttle("translations/ip24/#{key}", options) do |req|
      if req.path =~ %r{^/translate.*$} && req.post?
        req.ip.split('.').first(3).join('.')
      end
    end
  end

  self.throttled_response = lambda do |env|
    req = Rack::Request.new(env)
    Rails.logger.info "RequestThrottled ip=#{req.ip}"
   [ 503,  # status
     {},   # headers
     ['']] # body
  end
end
