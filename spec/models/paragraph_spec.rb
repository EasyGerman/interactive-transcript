require "rails_helper"

describe Paragraph do
  let(:html) {
    <<~HTML
      <p><strong>Manuel:</strong><br>[15:53] Da würde ich aber … Sag du mal.<br></p>
    HTML
  }
  let(:node) { Nokogiri::XML(html).css('p').first }
  subject(:paragraph) { described_class.new(node, double(:chapter), 0) }

  it "extracts the text after the timestamp" do
    expect(subject.text).to eq "Da würde ich aber … Sag du mal."
  end

  it "knows the timestamp" do
    expect(subject.timestamp.to_s).to eq "15:53"
    expect(subject.timestamp.to_seconds).to eq 15 * 60 + 53
  end

  it "knows the label" do
    expect(subject.label.to_s).to eq "Manuel:"
  end

  context "when the timestamp contains hours" do
    let(:html) {
      <<~HTML
        <p><strong>Manuel:</strong><br>[1:00:11] Da würde ich aber … Sag du mal.<br></p>
      HTML
    }

    it "finds the correct timestamp" do
      expect(subject.timestamp.to_seconds).to eq 3611
    end

    it "finds the correct text" do
      expect(subject.text).to eq "Da würde ich aber … Sag du mal."
    end

  end
end
