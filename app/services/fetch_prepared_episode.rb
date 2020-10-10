class FetchPreparedEpisode < Operation

  attribute :access_key, Types::String
  attribute :force_processing, Types::Bool.default(false)

  def call
    record = EpisodeRecord.find_by(access_key: access_key)
    if record.blank? || force_processing
      with_mutex do
        record = EpisodeRecord.find_by(access_key: access_key)
        if record.blank? || force_processing
          record = process
        end
      end
    end

    ::Processed::Episode.new(record.data)
  end

  private

  def process
    episode = Feed.new.episodes.find { |ep| ep.access_key == access_key }
    return if episode.blank?

    EpisodeRecord.upsert!(access_key, episode.processed.as_json)
  end

  def with_mutex
    RedisMutex.with_lock("process_episode:#{access_key}", block: 10, sleep: 0.5, expire: 30) do
      yield
    end
  end

end
