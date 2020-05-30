require "rails_helper"

describe EpisodeDescription do
  let(:html) {
    <<~HTML
      <p><strong>Manuel:</strong><br>[15:53] Da würde ich aber … Sag du mal.<br></p>
      <p><strong>Cari:</strong><br>[15:56] Naja, ich denke, …<br></p>
    HTML
  }
  subject { described_class.new(html) }

  describe "#processed_html" do
    it "contains tags for timestamps" do
      expect(subject.processed_html).to include %[<span class="timestamp" data-timestamp="953">[15:53]</span> Da würde]
      expect(subject.processed_html).to include %[<span class="timestamp" data-timestamp="956">[15:56]</span> Naja]
    end

    it "contains timestampedEntry classes" do
      expect(subject.processed_html).to include %[<p class="timestampedEntry"]
    end

    it "contains data-translation-id" do
      expect(subject.processed_html).to match %r{<p .* data-translation-id="#{Digest::SHA1.hexdigest("Da würde ich aber … Sag du mal.")}"}
    end

    it "populates translation cache (without translations)" do
      expect { subject.processed_html }.to change { TranslationCache.count }.by(2)
    end
  end

  describe "#paragraphs" do
    it "returns an object for each paragraph" do
      expect(subject.paragraphs[0].text).to eq "Da würde ich aber … Sag du mal."
      expect(subject.paragraphs[1].text).to eq "Naja, ich denke, …"
    end
  end
end
