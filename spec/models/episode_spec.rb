require "rails_helper"

describe Episode do
  let(:rss) {
    <<~XML
      <item>
        <title>28: Freundschaften in Deutschland (+ Bonus)</title>
        <link>https://www.patreon.com/posts/28-in-bonus-88888888</link>
        <description>#{CGI.escape_html(description_html)}</description>
        <enclosure url="https://example.com/1.mp3" length="1000000" type="audio/mpeg"/>
        <pubDate>Sat, 11 Apr 2020 16:09:20 GMT</pubDate>
      </item>
    XML
  }
  let(:description_html) {
    <<~HTML
      <p><strong>Manuel:</strong><br>[15:53] Da würde ich aber … Sag du mal.<br></p>
      <p><strong>Cari:</strong><br>[15:56] Naja, ich denke, …<br></p>
    HTML
  }
  let(:episode_node) { Nokogiri::XML(rss).css('item').first }
  subject(:episode) { described_class.new(episode_node) }

  it "provides the title" do
    expect(subject.title).to eq "28: Freundschaften in Deutschland (+ Bonus)"
  end

  it "provides the raw html" do
    expect(subject.html).to eq description_html
  end

  it "provides the audio url" do
    expect(subject.audio_url).to eq "https://example.com/1.mp3"
  end

  describe "#processed_html" do
    it "contains tags for timestamps" do
      expect(subject.processed_html).to include "<span class='timestamp' data-timestamp='953'>[15:53]</span> Da würde"
      expect(subject.processed_html).to include "<span class='timestamp' data-timestamp='956'>[15:56]</span> Naja"
    end
  end

  describe "#paragraphs" do
    it "returns an object for each paragraph" do
      expect(subject.paragraphs[0].text).to eq "Da würde ich aber … Sag du mal."
      expect(subject.paragraphs[1].text).to eq "Naja, ich denke, …"
    end
  end
end
