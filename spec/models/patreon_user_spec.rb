require "rails_helper"

RSpec.describe PatreonUser, vcr: false do
  # This test requires the file: data/patreon/current_user.json
  # You can get it by: (substitute xxx -> your access token, you can print it in PatreonAuthController)
  #   curl "https://www.patreon.com/api/oauth2/api/current_user" -H "Authorization: Bearer xxx" | json_pp > data/patreon/current_user.json

  before do
    easygerman.patreon_creator_id = "721253"
    easygerman.patreon_minimum_pledge = 1200
    easygerman.save!

  end

  describe "#has_access_to?" do
    subject { instance.has_access_to?(easygerman) }
    let!(:instance) {
      PatreonUser.create!(
        patreon_user_id: "2986651",
        oauth_data: token_payload("AccessToken1", "RefreshToken1"),
        user_data: {
          "pledges" => pledges,
        },
        access_token_expires_at: 1.day.from_now,
        last_synced_at: last_synced_at,
      )
    }
    let(:last_synced_at) { 1.second.ago }

    context "if the pledges contain the easygerman with a high enough pledge" do
      let(:pledges) {
        [
          {"creator_id"=>easygerman.patreon_creator_id, "amount_cents"=>easygerman.patreon_minimum_pledge},
        ]
      }
      it { is_expected.to eq true }
    end

    context "if the pledges contain the easygerman, but with a low pledge" do
      let(:pledges) {
        [
          {"creator_id"=>easygerman.patreon_creator_id, "amount_cents"=>easygerman.patreon_minimum_pledge - 100},
        ]
      }
      it { is_expected.to eq false }
    end

    context "if the pledges don't include easygerman" do
      let(:pledges) { [] }
      it { is_expected.to eq false }
    end

    context "if the user data was synced from Patreon more than a day ago" do
      let(:last_synced_at) { 3.days.ago }
      let(:pledges) { [] }

      before do
        stub_request(:get, "https://www.patreon.com/api/oauth2/api/current_user")
          .with(headers: { 'Authorization' => 'Bearer AccessToken1' })
          .to_return(status: 200, body: File.read(Rails.root.join('data', 'patreon', 'current_user.json')), headers: {})
      end

      it "syncs data from Patreon" do
        expect { subject }.to change { instance.reload.user_data }
      end

      it { is_expected.to eq true }
    end
  end

  describe "#fresh_access_token?" do
    subject { instance.fresh_access_token }
    let!(:instance) {
      PatreonUser.create!(
        patreon_user_id: "2986651",
        oauth_data: token_payload("AccessToken1", "RefreshToken1"),
        user_data: {
          "pledges" => [
            {"creator_id"=>"721253", "amount_cents"=>1200},
          ],
        },
        access_token_expires_at: access_token_expires_at,
        last_synced_at: 1.second.ago,
      )
    }

    context "if the access token doesn't expire soon" do
      let(:access_token_expires_at) { 1.days.from_now }

      it "doesn't refresh token" do
        expect { subject }.not_to change { instance.reload.access_token }
      end
    end

    context "if the access token expires soon" do
      let(:access_token_expires_at) { 30.seconds.from_now }

      before do
        stub_request(:post, "https://www.patreon.com/api/oauth2/token?client_id=x&client_secret=x&grant_type=refresh_token&refresh_token=RefreshToken1")
          .to_return(status: 200, body: token_payload("AccessToken2", "RefreshToken2").to_json, headers: {})
      end

      it "refreshes token" do
        expect { subject }.to change { instance.reload.access_token }
      end
    end
  end

  def token_payload(access_token, refresh_token)
    {
      "access_token"=> access_token,
      "expires_in"=>2678400,
      "token_type"=>"Bearer",
      "scope"=>"identity.memberships",
      "refresh_token"=>refresh_token,
      "version"=>"0.0.1",
    }
  end
end
