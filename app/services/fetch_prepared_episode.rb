class FetchPreparedEpisode < Operation
  include AwsUtils
  include Processor::Public::Methods

  attribute :podcast, Types.Instance(::Podcast)
  attribute :access_key, Types::String
  attribute :force_processing, Types::Bool.default(false)

  def call
    record = podcast.episode_records.find_by(access_key: access_key)
    if record.blank? || force_processing
      with_mutex do
        record = podcast.episode_records.find_by(access_key: access_key)
        if record.blank? || force_processing
          record = process_episode(podcast, access_key)
        end
      end
    end

    return if record.blank?
    ::Processed::Episode.new(record.data)
  end

  private

  def with_mutex
    RedisMutex.with_lock("process_episode:#{access_key}", block: 30, sleep: 0.5, expire: 60) do
      yield
    end
  end

end
