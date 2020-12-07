require "rails_helper"

describe TranslationCache do
  let(:podcast) { create_podcast }

  it "can store translations" do
    TranslationCache.create!(
      podcast_id: podcast.id,
      key: Digest::SHA1.hexdigest("Hallo"),
      original: "Hallo",
      translations: {
        "en" => "Hello",
      }
    )
  end

  it "can add an original paragraph without translations" do
    expect {
      TranslationCache.add_original_nx(podcast.id, "Hallo")
      TranslationCache.add_original_nx(podcast.id, "Hallo")
    }.to change { TranslationCache.count }.by(1)

    item = TranslationCache.lookup(podcast.id, "Hallo")
    expect(item.original).to eq "Hallo"
  end

  it "can add translation" do
    record = TranslationCache.add_original_nx(podcast.id, "Hallo")
    record.add_translation("en", "Hello")
    expect(record.get_translation("en")).to eq "Hello"
  end

  describe "with_key_cache" do
    let(:translator) { double(:translator) }

    it "uses block to get translation, but only once" do
      key = TranslationCache.add_original_nx(podcast.id, "Hallo").key
      expect(translator).to receive(:call).with("Hallo", "en").and_return("Hello").once

      result = TranslationCache.with_key_cache(podcast.id, key, "en") { |*args| translator.call(*args) }
      expect(result).to eq "Hello"

      result = TranslationCache.with_key_cache(podcast.id, key, "en") { |*args| translator.call(*args) }
      expect(result).to eq "Hello"
    end
  end

end
