module GoogleTranslate
  extend self
  extend Memoist

  def translate(text, to:, from: nil)
    contents = [text]
    target_language_code = to
    source_language_code = from

    response = client.translate_text(
      parent: parent,
      contents: contents,
      target_language_code: target_language_code,
      source_language_code: source_language_code,
    )

    response.translations.first.translated_text
  end

  def supported_source_languages
    response = client.get_supported_languages(parent: parent)
    response.languages.select(&:support_source).map do |langauge|
      langauge.language_code
    end
  end

  def supported_target_languages
    response = client.get_supported_languages(parent: parent)
    response.languages.select(&:support_target).map do |langauge|
      langauge.language_code
    end
  end

  private

  def location_id
    'us-central1'
  end

  def project_id
    JSON.parse(ENV['TRANSLATE_CREDENTIALS']).fetch('project_id')
  end

  def parent
    client.location_path(project: project_id, location: location_id)
  end

  def client
    Google::Cloud::Translate.translation_service
  end

end
