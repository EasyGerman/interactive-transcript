class FetchPreparedEpisode < Operation
  include AwsUtils

  attribute :podcast, Types.Instance(::Podcast)
  attribute :access_key, Types::String
  attribute :force_processing, Types::Bool.default(false)

  def call
    record = podcast.episode_records.find_by(access_key: access_key)
    if record.blank? || force_processing
      with_mutex do
        record = podcast.episode_records.find_by(access_key: access_key)
        if record.blank? || force_processing
          record = process
        end
      end
    end

    return if record.blank?
    ::Processed::Episode.new(record.data)
  end

  private

  def process
    episode = Feed.new(podcast).episodes.find { |ep| ep.access_key == access_key }
    return if episode.blank?

    episode_record = podcast.episode_records.upsert!(access_key, episode.processed.as_json)
    episode.audio.chapters.each do |chapter|
      next if chapter.picture.blank?
      episode_record.vocab_slide_records.upsert!(chapter.id, chapter.picture.data)
    end

    Concurrent::ScheduledTask.execute(2) do
      episode_record.vocab_slide_records.each do |slide|
        VocabSlide.new(slide, episode.access_key).upload
      end
    end

    episode_record
  end

  def with_mutex
    RedisMutex.with_lock("process_episode:#{access_key}", block: 30, sleep: 0.5, expire: 60) do
      yield
    end
  end

end
