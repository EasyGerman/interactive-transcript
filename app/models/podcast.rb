class Podcast < ApplicationRecord

  has_many :episode_records
  has_many :translation_caches

  def self.find_by_request!(request)
    find_by(host: request.host) || (first if Rails.env.development?) || raise(PodcastNotFound.new(request.host))
  end

  def feed
    Feed.new(self)
  end

  delegate :episodes, to: :feed

  def locale
    lang
  end

  def membership_url
    settings["membership_url"]
  end

  def homepage_url
    settings["membership_url"]
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

  def translations_enabled?
    translations_config&.fetch("enabled", false)
  end

  def word_highlighting_enabled?
    settings["word_highlighting"].present?
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

  def transcript_title
    settings.fetch("transcript_title", "Transcript")
  end

  def header_tags
    settings.fetch("header_tags", ["h2", "h3"])
  end

  def translator
    Translator.new(self)
  end

end
