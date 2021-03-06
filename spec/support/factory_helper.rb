module FactoryHelper
  SAMPLE_LANGUAGES = {
    de: 'german',
    ca: 'catalan',
    en: 'english',
    es: 'spanish',
    fr: 'french',
    pt: 'portugese',
    hu: 'hungarian',
    ro: 'romanian',
    ja: 'japanese',
    el: 'greek',
  }
  def create_podcast(attributes = {})
    @podcast_number ||= 0
    @podcast_number += 1

    lang = (attributes[:lang] ||= SAMPLE_LANGUAGES.keys[@podcast_number % SAMPLE_LANGUAGES.count])
    code = (attributes[:code] ||= "easy#{SAMPLE_LANGUAGES.fetch(lang)}")

    default_attributes = {
      name: "The Easy #{SAMPLE_LANGUAGES.fetch(lang).humanize} Podcast",
      lang: lang.to_s,
      host: "#{code}.example.com",
      feed_url: ENV.fetch('PODCAST_URL'),
      settings: {
        vocab_helper: {
          enabled: true,
          aws_bucket: "easygermanpodcastplayer-public",
          aws_region: "eu-central-1",
          aws_path: "vocab",
        },
        transcript_title: "Transkript",
      }
    }

    attributes = default_attributes.merge(attributes)

    ::Podcast.create!(attributes)
  end

  def find_or_create_podcast(code)
    Podcast.find_by(code: code) || create_podcast(code: code)
  end

  def easygerman
    Podcast.find_by(lang: 'de') || create_podcast(lang: :de)
  end
end
