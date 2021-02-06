module ApplicationHelper

  def rescue_and_show_errors(part = 'part')
    capture do
      yield
    end
  rescue StandardError => error
    Rollbar.error(error)
    content_tag :span, class: "error" do
      "Sorry, there is a problem with this #{part}"
    end
  end

  alias error_boundary rescue_and_show_errors

  def bilingual(separator: nil)
    locales = [I18n.locale, I18n.default_locale].uniq

    translations = {}
    locales.each do |locale|
      translation =
        capture do
          I18n.with_locale(locale) do
            yield
          end
        end
      next if translation.blank?
      next if translation.in?(translations.values)
      translations[locale] = translation
    end

    translations.map do |locale, translation|
      translation
    end.join(h(separator)).html_safe
  end

  def bilingual_paragraphs(key)
    bilingual do
      content_tag 'p', lang: locale do
        translate_optional(key, locale: locale)
      end
    end
  end

  def translate_optional(key, options)
    I18n.t!(key, options)
  rescue I18n::MissingTranslationData
    nil
  end

  def linkify_substring(container, link_label, href)
     link_html = capture do
       link_to link_label, href
     end
     h(container).gsub(h(link_label), link_html).html_safe
  end

  def collect_translations(keys, prefix: nil)
    if keys.is_a?(Hash)
      keys.map do |key, value|
        [key, collect_translations(value, prefix: "#{key}")]
      end.to_h
    elsif keys.is_a?(Array)
      if keys.any?
        keys.map do |key, value|
          [key, I18n.t([prefix, key].compact.join('.'))]
        end.to_h
      else
        I18n.t(prefix)
      end
    else
      [key, I18n.t([prefix, key].compact.join('.'))]
    end
  end
end
