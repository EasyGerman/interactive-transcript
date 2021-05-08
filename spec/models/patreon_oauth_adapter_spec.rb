require "rails_helper"

describe PatreonOauthAdapter do

  describe "#time_to_refresh_token?" do
    subject { described_class.new(patreon_user).time_to_refresh_token? }
    let(:patreon_user) { double(access_token_expires_at: expires_at) }

    context "if it expires in 30 days" do
      let(:expires_at) { 30.days.from_now }
      it { is_expected.to eq false }
    end

    context "if it expires in 6 minutes" do
      let(:expires_at) { 6.minutes.from_now }
      it { is_expected.to eq false }
    end

    context "if it expires in 4 minutes" do
      let(:expires_at) { 4.minutes.from_now }
      it { is_expected.to eq true }
    end

    context "if it expired 1 year ago" do
      let(:expires_at) { 1.year.ago }
      it { is_expected.to eq true }
    end
  end
end
