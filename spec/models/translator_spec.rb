require "rails_helper"

describe Translator do
  it "can translate", :vcr do
    expect(Translator.fetch_translation("Und hat es was gebracht?", "en")).to eq 'And did it work?'
  end

  it "can handle errors", :vcr do
    error = capture_error(Translator::Error) do
      Translator.fetch_translation("Und hat es was gebracht?", "esperanto")
    end

    expect(error).to be_present
    expect(error.message).to include "DeepL"
    expect(error.message).to include "Value for 'target_lang' not supported."
  end

  def capture_error(error_class)
    yield
    nil
  rescue error_class => error
    error
  end
end
