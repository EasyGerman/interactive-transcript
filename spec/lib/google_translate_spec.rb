require 'rails_helper'

describe GoogleTranslate do
  delegate :translate, :supported_source_languages, :supported_target_languages, to: :described_class

  let(:hungarian_text) { 'A klasszikus gitár fából készül, körülbelül egy méter hosszú, ennek nagyjából felét a nyak, felét a test teszi ki' }
  let(:expected_romanian_translation) { 'Chitara clasică este realizată din lemn, lungă de aproximativ un metru, aproximativ jumătate din ea este gâtul și jumătate este corpul.' }

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
      expect(supported_source_languages).to include('hu', 'ro')
      expect(supported_target_languages).to include('hu', 'ro')
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
