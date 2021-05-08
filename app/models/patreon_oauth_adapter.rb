class PatreonOauthAdapter

  extend Memoist

  REFRESH_TIME_BEFORE_EXPIRY = 5.minutes

  class Error < StandardError; end

  attr_reader :patreon_user

  class << self
    def redirect_uri
      ENV.fetch('PATREON_OAUTH_REDIRECT_URL')
    end
  end


  delegate :redirect_uri, to: :class

  def initialize(patreon_user = nil)
    @patreon_user = patreon_user
  end

  memoize def oauth_client
    Patreon::OAuth.new(
      ENV.fetch('PATREON_CLIENT_ID'),
      ENV.fetch('PATREON_CLIENT_SECRET'),
    )
  end

  def find_or_create_patreon_user_from_code(code)
    token_response = oauth_client.get_tokens(code, redirect_uri)
    Rails.logger.info "token response: #{token_response.inspect}"
    validate_token_response!(token_response)
    access_token = token_response["access_token"]

    user_response = PatreonClient.new(access_token).fetch_identity_with_memberships

    @patreon_user = PatreonUser.find_or_initialize_by(patreon_user_id: user_response.data.id)
    patreon_user.import_user_data_from_patreon_response(user_response)

    import_oauth_token(token_response)
    patreon_user.save!
    patreon_user
  end

  def fresh_access_token
    return access_token unless time_to_refresh_token?

    refresh_access_token

    access_token
  end

  def time_to_refresh_token?
    return true if patreon_user.access_token_expires_at.blank?
    patreon_user.access_token_expires_at < REFRESH_TIME_BEFORE_EXPIRY.from_now
  end

  def refresh_access_token
    token_response = oauth_client.refresh_token(refresh_token, redirect_uri)
    Rails.logger.info "token response for refresh: #{token_response.inspect}"
    validate_token_response!(token_response)
    import_oauth_token(token_response)
    patreon_user.save!
  end

  def validate_token_response!(token_response)
    if token_response.key?('error')
      raise Error, "Patreon authentication failed. Error message from the Patreon API while refreshing token: #{token_response['error']}"
    end

    if token_response['access_token'].blank?
      raise Error, "Patreon authentication failed. The Patreon API didn't return an access token."
    end
  end

  def import_oauth_token(token_response)
    patreon_user.oauth_data = token_response
    patreon_user.access_token_expires_at = Time.current + token_response.fetch("expires_in").to_i
  end

  def access_token
    patreon_user.oauth_data["access_token"]
  end

  def refresh_token
    patreon_user.oauth_data["refresh_token"]
  end

end
