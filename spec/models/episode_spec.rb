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
  let(:episode_node) { Nokogiri::XML(rss).css('item').first }
  subject(:episode) { described_class.new(podcast, fetcher, episode_node, feed) }
  let(:podcast) { find_or_create_podcast('easygerman') }
  let(:feed) { double(:feed, cover_url: "https://example.com/cover.jpg") }
  let(:fetcher) {
    double(
      :fetcher,
      fetch_downloadable_transcript: "<html>Downloadable</html>",
      fetch_editor_transcript: "<html>Editor</html>",
    )
  }
  let(:description_html) {
    <<~HTML
    <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
    <html><body>
    <p>Wir gehen unter die Podcaster! In unserer ersten Episode geht es um ...</p>
    <p><br></p>
    <h3><strong>Transkript und Vokabeln</strong></h3>
    <ul> <li>
    <strong>Transkript</strong> <ul> <li>Öffnen im <a href="https://play.easygerman.fm/episodes/1" rel="nofollow noopener" target="_blank">Transcript Player</a>
    </li> <li>Download als <a href="https://www.easygerman.org/s/egp1_transkript.html" rel="nofollow noopener" target="_blank">HTML</a>
    </li> <li>Download als <a href="https://www.easygerman.org/s/egp1_transkript.pdf" rel="nofollow noopener" target="_blank">PDF</a>
    </li> </ul> </li> <li>
    <strong>Vokabeln</strong> <ul> <li>Download als <a href="https://www.easygerman.org/s/egp1_vokabeln.txt" rel="nofollow noopener" target="_blank">Textdatei</a>
    </li> <li>Download mit <a href="https://www.easygerman.org/s/egp1_vokabeln-semikolon.txt" rel="nofollow noopener" target="_blank">Semikolon-Trennung</a> (für Vokabel-Apps)</li> </ul> </li>
    </ul>
    <p><br></p>
    <h3><strong>Transkript</strong></h3>
    <h3><strong>Intro</strong></h3>
    <p><strong>Cari:</strong><br>[0:00] Okay, Manuel. Jetzt musst du unseren Jingle abspielen!<br></p>
    <p><strong>Manuel:</strong><br>[0:31] Hallo Cari.<br></p>
    <p><strong>Cari:</strong><br>[0:32] Hallo Manuel.<br></p>
    <p><strong>Cari:</strong><br>[1:05:03] Tschüss und bis zur nächsten Woche.</p>
    </body></html>
    HTML
  }

  describe "#slug" do
    subject(:slug) { episode.slug }
    it { is_expected.to eq "28-in-bonus-88888888" }
  end

  describe "#title" do
    subject(:title) { episode.title }
    it { is_expected.to eq "28: Freundschaften in Deutschland (+ Bonus)" }
  end

  describe "#audio_url" do
    subject(:audio_url) { episode.audio_url }
    it { is_expected.to eq "https://example.com/1.mp3" }
  end

  describe "#published_at" do
    subject(:published_at) { episode.published_at }
    it { is_expected.to eq Time.parse('Sat, 11 Apr 2020 16:09:20 GMT') }
  end

  describe "#access_key" do
    subject(:access_key) { episode.access_key }
    it { is_expected.to eq "1" }
  end

  describe "#vocab_url" do
    subject(:vocab_url) { episode.vocab_url }
    it { is_expected.to eq "https://www.easygerman.org/s/egp1_vokabeln.txt" }
  end

  describe "#downloadable_html_url" do
    subject(:downloadable_html_url) { episode.downloadable_html_url }
    it { is_expected.to eq "https://www.easygerman.org/s/egp1_transkript.html" }
  end

  describe "#notes_html" do
    subject(:notes_html) { episode.notes_html }
    it { is_expected.to start_with "<p>Wir gehen unter die Podcaster!" }
    it { is_expected.to end_with "<p><br></p>" }
  end

  describe "#chapters" do
    subject(:chapters) { episode.chapters }
    it { expect(chapters.count).to eq 1 }
  end

  describe "#transcript" do
    subject(:transcript) { episode.transcript }
    it { is_expected.to be_a TranscriptFromFeed }
  end

  describe "#downloadable_html" do
    subject(:downloadable_html) { episode.downloadable_html }
    it { is_expected.to eq '<html>Downloadable</html>' }
  end

  describe "#transcript_editor_html" do
    subject(:transcript_editor_html) { episode.transcript_editor_html }
    it { is_expected.to eq '<html>Editor</html>' }
  end

  describe "#timed_script" do
    subject(:timed_script) { episode.timed_script }
    it { is_expected.to be_a TimedScript }
  end

  describe "#audio" do
    subject(:audio) { episode.audio }
    it { is_expected.to be_a Audio }
  end

  describe "#vocab" do
    subject(:vocab) { episode.vocab }
    it { is_expected.to be_a Vocab }
  end

  describe "#processed" do
    subject(:processed) { episode.processed }

    before do
      allow(Audio).to receive_message_chain(:new).and_return(
        double(:audio, processed_chapters: nil)
      )
    end

    it { is_expected.to be_a ::Processed::Episode }

    describe "#as_json" do
      subject { processed.as_json }

      it do
        expect(subject['title']).to eq '28: Freundschaften in Deutschland (+ Bonus)'
        expect(subject['cover_url']).to eq 'https://example.com/cover.jpg'
        expect(subject['audio_url']).to eq 'https://example.com/1.mp3'
        expect(subject['notes_html']).to start_with '<p>Wir gehen'
        expect(subject['chapters'][0]['title']).to eq 'Intro'
        expect(subject['chapters'][0]['paragraphs'].count).to eq 4

        paragraph = subject['chapters'][0]['paragraphs'][0]
        expect(paragraph['translation_id']).to match /^[0-9a-f]+$/
        expect(paragraph['slug']).to match /^[0-9a-f]+$/
        expect(paragraph['speaker']['name']).to eq 'Cari'
        expect(paragraph['timestamp']['text']).to eq '0:00'
        expect(paragraph['timestamp']['seconds']).to eq 0
        expect(paragraph['text']).to eq 'Okay, Manuel. Jetzt musst du unseren Jingle abspielen!'
      end
    end
  end
end
