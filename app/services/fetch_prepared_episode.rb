class FetchPreparedEpisode < Operation

  attribute :access_key, Types::String
  attribute :force_processing, Types::Bool.default(false)

  def call
    record = EpisodeRecord.find_by(access_key: access_key)

    if record.blank? || force_processing
      feed = Feed.new

      episode = feed.episodes.find { |ep| ep.access_key == access_key }
      return if episode.blank?

      if record.present?
        record.update!(
          data: episode.processed.as_json,
        )
      else
        record = EpisodeRecord.create!(
          access_key: access_key,
          data: episode.processed.as_json,
        )
      end
    end

    ::Processed::Episode.new(record.data)
  end

end
