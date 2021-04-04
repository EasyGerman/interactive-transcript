class Podcast < ApplicationRecord

  has_many :episode_records
  has_many :translation_caches

  validate :validate_settings_json

  class << self
    def settings_attribute(name, path = nil, json: false, default: nil, bool: false)
      path ||= [name.to_s]

      define_method name do
        settings.dig(*path) || default
      end

      if bool
        define_method "#{name}?" do
          settings.dig(*path) || default
        end
      end

      define_method "#{name}=" do |value|
        value = JSON.parse(value) if json && value.is_a?(String)
        value = value.in?(%w[1 on true yes]) if bool && value.is_a?(String)
        iter_box = settings
        path[0..-2].each_with_index do |path_item, i|
          iter_box = (iter_box[path_item] ||= {})
        end
        iter_box[path.last] = value
      end

    end
  end


  settings_attribute :membership_url
  settings_attribute :homepage_url
  settings_attribute :vocab_helper_enabled, %w[vocab_helper enabled], bool: true
  settings_attribute :transcript_title, default: "Transcript"
  settings_attribute :translations_enabled, %w[translations enabled], bool: true
  settings_attribute :translations_languages, %w[translations languages]
  settings_attribute :google_credentials, %w[translations services google credentials], json: true
  settings_attribute :word_highlighting_enabled, %w[word_highlighting enabled], bool: true
  settings_attribute :word_highlighting_version, %w[word_highlighting version]
  settings_attribute :editor_transcript_dropbox_access_key, %w[editor_transcript dropbox_access_key]
  settings_attribute :editor_transcript_dropbox_shared_link, %w[editor_transcript dropbox_shared_link]
  settings_attribute :header_tags, json: true, default: ["h2", "h3"]

  def validate_settings_json
    return if settings.is_a?(Hash)
    errors.add(:settings, "must be a hash")
  end

  def feed
    Feed.new(self)
  end

  delegate :episodes, to: :feed

  def locale
    lang
  end

  def vocab_helper_config
    settings["vocab_helper"]
  end

  def vocab_helper_enabled?
    vocab_helper_config&.fetch("enabled", false)
  end

  def translations_config
    settings["translations"]
  end

  def vocab_helper_aws_bucket
    vocab_helper_config["aws_bucket"]
  end

  def vocab_helper_aws_region
    vocab_helper_config["aws_region"]
  end

  def vocab_helper_aws_path
    vocab_helper_config["aws_path"]
  end

  def vocab_helper_image_access_url_template
    "https://#{vocab_helper_aws_bucket}.s3.#{vocab_helper_aws_region}.amazonaws.com"\
      "/#{vocab_helper_aws_path}/{{access_key}}/{{chapter_key}}.jpg"
  end

  def vocab_helper_image_access_url(access_key, chapter_key)
    "https://#{vocab_helper_aws_bucket}.s3.#{vocab_helper_aws_region}.amazonaws.com"\
      "/#{vocab_helper_aws_path}/#{access_key}/#{chapter_key}.jpg"
  end

  def editor_transcript_config
    settings["editor_transcript"]
  end

  def homepage_url
    settings["homepage_url"]
  end

  def homepage_url_display
    return if homepage_url.blank?
    URI.parse(homepage_url).host
  end

  def translator
    Translator.new(self)
  end

end
