require "rails_helper"

describe Timestamp do
  describe ".tag_in_html" do
    let(:result) { described_class.tag_in_html(html) }
    let(:html) {
      <<~HTML
        <p><strong>Manuel:</strong><br>[15:53] Da würde ich aber … Sag du mal.<br></p>
        <p><strong>Cari:</strong><br>[15:56] Naja, ich denke, ....<br></p>
      HTML
    }

    it "contains tags for timestamps" do
      expect(result).to include "<span class='timestamp' data-timestamp='953'>[15:53]</span> Da würde"
      expect(result).to include "<span class='timestamp' data-timestamp='956'>[15:56]</span> Naja"
    end
  end

  describe ".convert_string_to_seconds" do
    it "works when the minute are zero" do
      expect(Timestamp.convert_string_to_seconds("0:13")).to eq 13
      expect(Timestamp.convert_string_to_seconds("00:13")).to eq 13
    end

    it "works when the hour is zero" do
      expect(Timestamp.convert_string_to_seconds("0:01:13")).to eq 73
      expect(Timestamp.convert_string_to_seconds("00:01:13")).to eq 73
    end

    it "works when the hour is non-zero" do
      expect(Timestamp.convert_string_to_seconds("1:01:13")).to eq 3673
      expect(Timestamp.convert_string_to_seconds("01:01:13")).to eq 3673
    end
  end

  describe "REGEX" do
    it "works when the minute are zero" do
      expect(Timestamp::REGEX.match("[0:13]")[1]).to eq "0:13"
      expect(Timestamp::REGEX.match("[00:13]")[1]).to eq "00:13"
    end

    it "works when the hour is zero" do
      expect(Timestamp::REGEX.match("[0:01:13]")[1]).to eq "0:01:13"
      expect(Timestamp::REGEX.match("[00:01:13]")[1]).to eq "00:01:13"
    end

    it "works when the hour is non-zero" do
      expect(Timestamp::REGEX.match("[1:01:13]")[1]).to eq "1:01:13"
      expect(Timestamp::REGEX.match("[01:01:13]")[1]).to eq "01:01:13"
    end

    it "works when surrounded by other stuff" do
      expect(Timestamp::REGEX.match("hallo [1:01:13] hi")[1]).to eq "1:01:13"
    end
  end

  describe ".from_seconds" do
    it "works when the minute are zero" do
      expect(Timestamp.from_seconds(13).to_s).to eq("0:13")
    end

    it "works when the hour is zero" do
      expect(Timestamp.from_seconds(73).to_s).to eq("1:13")
    end

    it "works when the hour is non-zero" do
      expect(Timestamp.from_seconds(3673).to_s).to eq("1:01:13")
    end
  end

  describe ".new + .to_s" do
    context "when there are some extra characters" do
      it "works when the minute are zero" do
        expect(Timestamp.new("0:13]").to_s).to eq "0:13"
        expect(Timestamp.new("00:13]").to_s).to eq "00:13"
      end

      it "works when the hour is zero" do
        expect(Timestamp.new("0:01:13]").to_s).to eq "0:01:13"
        expect(Timestamp.new("00:01:13]").to_s).to eq "00:01:13"
      end

      it "works when the hour is non-zero" do
        expect(Timestamp.new("1:01:13]").to_s).to eq "1:01:13"
        expect(Timestamp.new("01:01:13]").to_s).to eq "01:01:13"
      end
    end
  end
end
