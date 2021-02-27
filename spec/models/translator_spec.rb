require "rails_helper"

describe Translator do
  delegate :translate_with_cache, :translate_from_key, :fetch_translation, :supported_target_languages_for, to: :translator

  let(:podcast) {
    find_or_create_podcast('easygerman').tap do |podcast|
      podcast.settings["translations"] = translations_config
      podcast.save!
    end
  }

  let(:translations_config) {
    {
      # "languages" => "en,ar,ko,fa,fi,lv,vi,he,ja,da,sv,id,ro,sk,cs,hu,tr,fr,it,es,nl,pl,pt,ru,zh",
      "languages" => "en,ja,fr,it,es,nl,pl,pt,ru,zh",
      "services" => {
        "deepl" => { "credentials" => { "api_key" => ENV.fetch("DEEPL_API_KEY") } },
        "google" => { "credentials" => ENV.fetch("TRANSLATE_CREDENTIALS") },
      }
    }
  }

  let(:translator) {
    Translator.new(podcast)
  }

  context 'with network', network: true do
    it 'translates English to German' do
      expect(fetch_translation('Gift', from: 'en', to: 'de')).to eq('Geschenk')
    end

    it 'translates German to English' do
      expect(fetch_translation('Gift', from: 'de', to: 'en')).to eq('Poison')
    end

    it 'translates English to Hungarian' do
      expect(fetch_translation('Gift', from: 'en', to: 'hu')).to eq('Ajándék')
    end

    it 'translates German to Hungarian' do
      expect(fetch_translation('Gift', from: 'de', to: 'hu')).to eq('Méreg')
    end
  end

  context 'with recorded network' do
    it "can translate", :vcr do
      expect(fetch_translation("Und hat es was gebracht?", from: "de", to: "en")).to eq(['And did it do anything?', cache_key: 'EN'])
    end

    it "can handle errors", :vcr do
      error = capture_error(Translator::Error) do
        fetch_translation("Und hat es was gebracht?", from: "de", to: "zh")
      end

      expect(error).to be_present
      expect(error.message).to include "DeepL"
      expect(error.message).to include "Error 888"
    end
  end

  context 'with mocked network' do
    let!(:deepl_translator) { DeeplTranslator.new(credentials: double()).tap { |translator| allow(DeeplTranslator).to receive(:new).and_return(translator) } }
    let!(:google_translator) { GoogleTranslate.new(credentials: double()).tap { |translator| allow(GoogleTranslate).to receive(:new).and_return(translator) } }

    it 'caches translations (DeepL)' do
      expect(deepl_translator).to receive(:translate).with('Gift', from: 'de', to: 'en').once.and_return('Poison')
      expect(translate_with_cache('Gift', to: 'en')).to eq 'Poison'
      expect(translate_with_cache('Gift', to: 'EN')).to eq 'Poison'
      expect(TranslationCache.lookup(podcast, 'Gift').translations.keys).to eq ["EN"]
      key = TranslationCache.lookup(podcast, 'Gift').key
      expect(translate_from_key(key, to: 'EN')).to eq 'Poison'
    end

    it 'caches translations (Google)' do
      expect(google_translator).to receive(:translate).with('Gift', from: 'de', to: 'hu').once.and_return('Méreg')
      expect(translate_with_cache('Gift', to: 'hu')).to eq 'Méreg'
      expect(translate_with_cache('Gift', to: 'HU')).to eq 'Méreg'
      expect(TranslationCache.lookup(podcast, 'Gift').translations.keys).to eq ["hu@google"]
    end

    it 'caches translations (de-pt => DeepL)' do
      expect(deepl_translator).to receive(:translate).with('Gift', from: 'de', to: 'pt').once.and_return('Poção')
      expect(translate_with_cache('Gift', to: 'pt')).to eq 'Poção'
      expect(translate_with_cache('Gift', to: 'pt-PT')).to eq 'Poção'
      expect(TranslationCache.lookup(podcast, 'Gift').translations.keys).to eq ["PT-PT"]
    end

    context "when the podcast language is Catalan" do
      let(:podcast) {
        find_or_create_podcast('easycatalan').tap do |podcast|
          podcast.settings["translations"] = translations_config
          podcast.save!
        end
      }

      it 'caches translations (ca-EN => Google)' do
        expect(google_translator).to receive(:translate).with('Hola', from: 'ca', to: 'EN').once.and_return('Hello')
        expect(translate_with_cache('Hola', to: 'EN')).to eq 'Hello'
        expect(translate_with_cache('Hola', to: 'en')).to eq 'Hello'
        expect(TranslationCache.lookup(podcast, 'Hola').translations.keys).to eq ["en@google"]
      end
    end

    it 'returns Easy German target languages for select' do
      expect(translator.supported_target_languages_for_select).to eq [
        # ["Arabic", "AR", {"data-service"=>"Google Translate"}],
        ["Chinese", "ZH", {"data-service"=>"DeepL"}],
        # ["Czech", "CS", {"data-service"=>"Google Translate"}],
        # ["Danish", "DA", {"data-service"=>"Google Translate"}],
        ["Dutch", "NL", {"data-service"=>"DeepL"}],
        ["English", "EN", {"data-service"=>"DeepL"}],
        # ["Finnish", "FI", {"data-service"=>"Google Translate"}],
        ["French", "FR", {"data-service"=>"DeepL"}],
        # ["Hebrew", "HE", {"data-service"=>"Google Translate"}],
        # ["Hungarian", "HU", {"data-service"=>"Google Translate"}],
        # ["Indonesian", "ID", {"data-service"=>"Google Translate"}],
        ["Italian", "IT", {"data-service"=>"DeepL"}],
        ["Japanese", "JA", {"data-service"=>"DeepL"}],
        # ["Korean", "KO", {"data-service"=>"Google Translate"}],
        # ["Latvian", "LV", {"data-service"=>"Google Translate"}],
        # ["Persian", "FA", {"data-service"=>"Google Translate"}],
        ["Polish", "PL", {"data-service"=>"DeepL"}],
        ["Portuguese", "PT", {"data-service"=>"DeepL"}],
        # ["Romanian", "RO", {"data-service"=>"Google Translate"}],
        ["Russian", "RU", {"data-service"=>"DeepL"}],
        # ["Slovak", "SK", {"data-service"=>"Google Translate"}],
        ["Spanish", "ES", {"data-service"=>"DeepL"}],
        # ["Swedish", "SV", {"data-service"=>"Google Translate"}],
        # ["Turkish", "TR", {"data-service"=>"Google Translate"}],
        # ["Vietnamese", "VI", {"data-service"=>"Google Translate"}],
      ]
    end
  end
end
