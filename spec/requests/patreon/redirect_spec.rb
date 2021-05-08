require "rails_helper"

RSpec.describe "GET /patreon/redirect", type: :request, vcr: false do
  # This test requires the file: identity_with_memberships/easygerman.json
  # Steps to generate this file:
  #   1. get an access token via PatreonAuthController
  #   2. execute the request in this test starting with https://www.patreon.com/api/oauth2/v2/identity

  before do
    easygerman.host = "www.example.com"
    easygerman.patreon_creator_id = "721253"
    easygerman.patreon_minimum_pledge = 1200
    easygerman.save!

    token_response_payload = {
      "access_token"=>"AccessToken1",
      "expires_in"=>2678400,
      "token_type"=>"Bearer",
      "scope"=>"identity.memberships",
      "refresh_token"=>"RefreshToken1",
      "version"=>"0.0.1",
    }
    stub_request(:post, "https://www.patreon.com/api/oauth2/token?client_id=x&client_secret=x&code=CoreFromPatreon1&grant_type=authorization_code&redirect_uri=http://www.example.com/patreon/redirect")
      .to_return(status: 200, body: token_response_payload.to_json, headers: {})

    stub_request(:get, "https://www.patreon.com/api/oauth2/v2/identity?fields%5Bmember%5D=patron_status,currently_entitled_amount_cents&fields%5Buser%5D=full_name,first_name,thumb_url&include=memberships,memberships.campaign,memberships.campaign.creator")
      .with(headers: { 'Authorization' => 'Bearer AccessToken1' })
      .to_return(status: 200, body: File.read(Rails.root.join('data', 'patreon', 'identity_with_memberships/easygerman.json')), headers: {})
  end

  it "saves token & pledges to database" do
    expect {
      get "/patreon/redirect", params: { code: "CoreFromPatreon1", state: easygerman.id }
    }.to change { PatreonUser.count }.by(1)

    patreon_user = PatreonUser.last

    expect(patreon_user.oauth_data["access_token"]).to eq "AccessToken1"
    expect(patreon_user.oauth_data["refresh_token"]).to eq "RefreshToken1"

    expect(patreon_user.pledge_for(easygerman).amount_cents).to eq 1200
    expect(patreon_user.has_access_to?(easygerman)).to eq true
  end
end
