module FactoryHelper
  def create_podcast
    @podcast_number ||= 0
    @podcast_number += 1
    ::Podcast.create!(
      code: "easygerman#{@podcast_number}",
      name: "The Easy German Podcast #{@podcast_number}",
      lang: ['de', 'en', 'es', 'fr', 'pt', 'hu', 'ro', 'ja', 'nl'][@podcast_number - 1],
      host: 'www.example.com',
      feed_url: ENV.fetch('PODCAST_URL'),
      settings: {
        vocab_helper: {
          enabled: true,
          aws_bucket: "easygermanpodcastplayer-public",
          aws_region: "eu-central-1",
          aws_path: "vocab",
        },
      }
    )
  end
end
