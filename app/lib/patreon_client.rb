class PatreonClient
  attr_reader :access_token

  def initialize(access_token)
    @access_token = access_token
  end

  def fetch_identity_with_memberships
    path = Patreon::Utils::JSONAPI::URLUtil.build_url(
      '/api/oauth2/v2/identity',
      [
        "memberships",
        "memberships.campaign",
        "memberships.campaign.creator",
      ],
      {
        user: "full_name,first_name,thumb_url",
        member: "patron_status,currently_entitled_amount_cents",
      },
    )

    response = Faraday.get("https://www.patreon.com" + path) do |req|
      req.headers["Authorization"] = "Bearer #{access_token}"
    end

    JSON::Api::Vanilla.parse(response.body)
  end
end
