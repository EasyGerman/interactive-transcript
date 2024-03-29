require 'rails_helper'

describe GoogleTranslate do
  delegate :translate, :supported_languages, to: :instance

  let(:instance) {
    described_class.new(credentials: JSON.parse(ENV.fetch("TRANSLATE_CREDENTIALS")))
  }

  let(:hungarian_text) { 'A klasszikus gitár fából készül, körülbelül egy méter hosszú, ennek nagyjából felét a nyak, felét a test teszi ki' }
  let(:expected_romanian_translation) { 'Chitara clasică este fabricată din lemn, lungă de aproximativ un metru, din care aproximativ jumătate este gâtul și jumătate din corp.' }

  context 'with network', network: true do
    context 'without specifying the source language' do
      it 'translates a text from Hungarian to Romanian' do
        expect(translate(hungarian_text, to: 'ro')).to eq(expected_romanian_translation)
      end
    end

    context 'with specifying the source language' do
      it 'translates "Gift" as "present" if source is English' do
        expect(translate('Gift', from: 'en', to: 'hu')).to eq('Ajándék')
      end

      it 'translates "Gift" as "poison" if source is German' do
        expect(translate('Gift', from: 'de', to: 'hu')).to eq('Méreg')
      end
    end

    it 'can get the supported languages' do
      result = supported_languages(cached: false)

      expect(result.map { |lang| lang[:code] }).to include('hu', 'ro', 'ceb', 'pa', 'zh', 'zh-CN', 'zh-TW')

      # It doesn't include deprecated codes
      expect(result.map { |lang| lang[:code] }).not_to include('iw', 'jw')

      # Uses name from the constant if available
      expect(result).to include(code: 'ro', name: 'Romanian', source: true, target: true)
    end

    it 'returns unescaped string' do
      expect(translate('in einer Folge "Fest & Flauschig"', from: 'de', to: 'en')).to eq('in one episode "Fest & Fluschig"')
    end
  end

  context 'with stubbed client' do
    before do
      stub_env(TRANSLATE_CREDENTIALS: { project_id: "projectid1" }.to_json)
    end

    context 'without specifying the source language' do
      it 'translates a text from Hungarian to Romanian' do
        stub_translate_text contents: [hungarian_text],
                            source_language_code: nil,
                            target_language_code: 'ro',
                            translated_texts: [expected_romanian_translation]

        expect(translate(hungarian_text, to: 'ro')).to eq(expected_romanian_translation)
      end
    end

    context 'with specifying the source language' do
      it 'translates "Gift" as "present" if source is English' do
        stub_translate_text contents: ['Gift'],
                            source_language_code: 'en',
                            target_language_code: 'hu',
                            translated_texts: ['Ajándék']

        expect(translate('Gift', from: 'en', to: 'hu')).to eq('Ajándék')
      end

      it 'translates "Gift" as "poison" if source is German' do
        stub_translate_text contents: ['Gift'],
                            source_language_code: 'de',
                            target_language_code: 'hu',
                            translated_texts: ['Méreg']

        expect(translate('Gift', from: 'de', to: 'hu')).to eq('Méreg')
      end
    end

    it 'returns unescaped string' do
      stub_translate_text contents: ['in einer Folge "Fest & Flauschig"'],
                          source_language_code: 'de',
                          target_language_code: 'en',
                          translated_texts: ['in one episode &quot;Fest &amp; Fluschig&quot;']

      expect(translate('in einer Folge "Fest & Flauschig"', from: 'de', to: 'en')).to eq('in one episode "Fest & Fluschig"')
    end

    it 'can get supported languages (cached)' do
      expect(supported_languages).to include(
        code: 'ro',
        name: 'Romanian',
        source: true,
        target: true,
      )
    end
  end

  def stub_translate_text(contents:, source_language_code:, target_language_code:, translated_texts:)
    translation_service = double(:translation_service)
    allow(Google::Cloud::Translate).to receive(:translation_service).and_return(translation_service)
    allow(translation_service).to receive(:location_path).with(project: 'projectid1', location: 'us-central1').and_return(:parent_returned_by_location_path)
    translation_service
    allow(translation_service)
      .to receive(:translate_text)
      .with(
        parent: :parent_returned_by_location_path,
        contents: contents,
        source_language_code: source_language_code,
        target_language_code: target_language_code,
      )
      .and_return(
        double(
          :response,
          translations: translated_texts.map { |translated_text|
            double(:translation, translated_text: translated_text)
          }
        )
      )
  end
end
