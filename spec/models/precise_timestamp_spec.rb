require "rails_helper"

describe PreciseTimestamp do
  delegate :from, to: PreciseTimestamp

  describe ".from" do
    it "works when the minute are zero" do
      expect(from(13.0169).to_s).to eq("0:13.017")
      expect(from(13.0169).to_seconds).to eq(13.0169)
    end

    it "works when the hour is zero" do
      expect(from(73.0169).to_s).to eq("1:13.017")
    end

    it "works when the hour is non-zero" do
      expect(from(3673.0169).to_s).to eq("1:01:13.017")
    end

    it "can handle a PreciseTimestamp instance" do
      instance = from(3673.0169)
      expect(from(instance).to_s).to eq("1:01:13.017")
    end

    it "can handle nil" do
      expect(from(nil)).to eq nil
    end

    it "can handle a string" do
      expect(from("0:13.0169").to_s).to eq("0:13.017")
      expect(from("1:01:13.0169").to_s).to eq("1:01:13.017")
    end
  end
end
