require "rails_helper"

describe Translator do
  delegate :translate_with_cache, :fetch_translation, :supported_target_languages_for, to: :described_class

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
      expect(Translator.fetch_translation("Und hat es was gebracht?", from: "de", to: "en")).to eq(['And did it do anything?', cache_key: 'EN'])
    end

    it "can handle errors", :vcr do
      error = capture_error(Translator::Error) do
        Translator.fetch_translation("Und hat es was gebracht?", from: "de", to: "zh")
      end

      expect(error).to be_present
      expect(error.message).to include "DeepL"
      expect(error.message).to include "Error 888"
    end
  end

  context 'with mocked network' do
    let(:podcast) { find_or_create_podcast('easygerman') }

    it 'caches translations (DeepL)' do
      expect(DeeplTranslator).to receive(:translate).with('Gift', from: 'de', to: 'en').once.and_return('Poison')
      expect(translate_with_cache(podcast, 'Gift', to: 'en')).to eq 'Poison'
      expect(translate_with_cache(podcast, 'Gift', to: 'EN')).to eq 'Poison'
      expect(TranslationCache.lookup(podcast, 'Gift').translations.keys).to eq ["EN"]
    end

    it 'caches translations (Google)' do
      expect(GoogleTranslate).to receive(:translate).with('Gift', from: 'de', to: 'hu').once.and_return('Méreg')
      expect(translate_with_cache(podcast, 'Gift', to: 'hu')).to eq 'Méreg'
      expect(translate_with_cache(podcast, 'Gift', to: 'HU')).to eq 'Méreg'
      expect(TranslationCache.lookup(podcast, 'Gift').translations.keys).to eq ["hu@google"]
    end

    it 'caches translations (de-pt => DeepL)' do
      expect(DeeplTranslator).to receive(:translate).with('Gift', from: 'de', to: 'pt').once.and_return('Poção')
      expect(translate_with_cache(podcast, 'Gift', to: 'pt')).to eq 'Poção'
      expect(translate_with_cache(podcast, 'Gift', to: 'pt-PT')).to eq 'Poção'
      expect(TranslationCache.lookup(podcast, 'Gift').translations.keys).to eq ["PT-PT"]
    end

    context "when the podcast language is Catalan" do
      let(:podcast) { find_or_create_podcast('easycatalan') }

      it 'caches translations (ca-EN => Google)' do
        expect(GoogleTranslate).to receive(:translate).with('Hola', from: 'ca', to: 'EN').once.and_return('Hello')
        expect(translate_with_cache(podcast, 'Hola', to: 'EN')).to eq 'Hello'
        expect(translate_with_cache(podcast, 'Hola', to: 'en')).to eq 'Hello'
        expect(TranslationCache.lookup(podcast, 'Hola').translations.keys).to eq ["en@google"]
      end
    end

    it 'returns supported languages' do
      codes = supported_target_languages_for('ro').map(&:language_with_region_code)
      expect(codes).not_to include('ro')
      expect(codes).to include('hu')
      expect(codes).to include('en')
      expect(codes).to include('pt')
      expect(codes).to include('pt')
      expect(codes).not_to include('pt-BR') # only DeepL supports pt-BR, Google does not
      expect(codes).not_to include('pt-PT') # avoid duplication, we have plain 'pt'

      codes = supported_target_languages_for('de').map(&:language_with_region_code)
      expect(codes).not_to include('de')
      expect(codes).to include('hu')
      expect(codes).to include('ro')
      expect(codes).to include('en')
      expect(codes).to include('pt')
      expect(codes).to include('pt-BR')
      expect(codes).not_to include('pt-PT') # avoid duplication, we have plain 'pt'
    end

  end

end
