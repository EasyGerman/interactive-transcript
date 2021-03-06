require "rails_helper"

describe Translation do
  subject { described_class.new(valid_attributes) }

  let(:valid_attributes) {
    {
      key: translation_cache.key,
      translation_cache: translation_cache,
      source_lang: 'de',
      lang: 'en',
      translation_service: 'deepl',
      source_length: 7,
      body: 'Hello!',
    }
  }

  let(:translation_cache) { TranslationCache.add_original_nx(podcast, "Hallo!") }
  let(:podcast) { create_podcast }

  describe "when valid attributes were provided" do
    it { is_expected.to be_valid }
  end

  describe "lang validation" do
    context "when lowercase and exists" do
      before { subject.lang = 'en' }
      it { is_expected.to be_valid }
    end

    context "when not lowercase" do
      before { subject.lang = 'En' }
      it { is_expected.not_to be_valid }
    end

    context "when not valid" do
      before { subject.lang = 'aa' }
      it { is_expected.not_to be_valid }
    end
  end

  describe "source_lang validation" do
    context "when lowercase and exists" do
      before { subject.source_lang = 'en' }
      it { is_expected.to be_valid }
    end

    context "when not lowercase" do
      before { subject.source_lang = 'En' }
      it { is_expected.not_to be_valid }
    end

    context "when not valid" do
      before { subject.source_lang = 'aa' }
      it { is_expected.not_to be_valid }
    end
  end

  describe "region validation" do
    context "when 2-letter uppercase" do
      before { subject.region = 'GB' }
      it { is_expected.to be_valid }
    end

    context "when not uppercase" do
      before { subject.region = 'gb' }
      it { is_expected.not_to be_valid }
    end
  end

  describe "translation service validation" do
    context "when it's a valid one" do
      before { subject.translation_service = 'google' }
      it { is_expected.to be_valid }
    end

    context "when not a valid one" do
      before { subject.translation_service = 'yahoo' }
      it { is_expected.not_to be_valid }
    end
  end
end