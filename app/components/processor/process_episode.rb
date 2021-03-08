module Processor
  class ProcessEpisode < ::Operation
    attribute :podcast, Types.Instance(::Podcast)
    attribute :access_key, Types::String

    def call
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
  end
end