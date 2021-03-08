require "rails_helper"

# Integration test for verifying that the processing provides the same results
# as previous runs.
#
# Preparing the files:
# PODCAST=easygerman bundle exec rake feed:import_to_files
#
# Running the specs:
# EPISODES=all bundle exec rspec spec/modules/processing_spec.rb
#
describe "Processing", :data, vcr: false do
  podcasts =
    if podcast_specifier = ENV['PODCAST'].presence
      [Podcast.find_by!(code: podcast_specifier)]
    else
      Podcast.all.to_a
    end

  podcasts.each do |podcast|
    fetcher = ContentProvider.for_podcast(podcast)
    feed = Feed.new(podcast, fetcher)

    episodes = feed.episodes
    episodes =
      case ENV['EPISODES']
      when '', nil then []
      when 'l', 'latest' then [episodes.first]
      when /^l(\d+)$/ then episodes.first($1.to_i)
      when 'r', 'rand' then [episodes.sample]
      when /^r(\d+)$/ then episodes.sample($1.to_i)
      when 'a', 'all' then episodes
      when /^(\d+)$/ then episodes.select { |e| e.number == $1.to_i }
      when /^(\d+)..(\d+)$/ then episodes.select { |e| e.number >= $1.to_i && e.number <= $2.to_i }
      else raise "Unrecognized value for EPISODES: #{ENV['EPISODES'].inspect}"
      end

    episodes.each do |episode|
      if episode.transcript.blank?
        puts "Transcript missing for #{podcast.name} episode #{episode.number}"
        next
      end

      it "processes episode '#{episode.slug}' correctly" do
        WebMock.allow_net_connect!
        VCR.turn_off!

        fetcher_for_episode = fetcher.for_episode(episode)

        actual_yaml = YAML.dump(episode.processed.as_json)
        expected_yaml =
          begin
            fetcher_for_episode.fetch_processed_yaml
            # CONFLICT:
            # fetcher.fetch_processed_yaml(episode)
          rescue Errno::ENOENT
            nil
          end

        episode_path = fetcher_for_episode.root_path
        path_to_expected = episode_path.join("processed.yaml")
        path_to_actual = episode_path.join("processed-actual.yaml")

        if expected_yaml.blank?
          fetcher_for_episode.write_file(path_to_expected, actual_yaml)
        elsif actual_yaml != expected_yaml
          if ENV['OVERWRITE'].present?
            fetcher_for_episode.write_file(path_to_expected, actual_yaml)
          else
            fetcher_for_episode.write_file(path_to_actual, actual_yaml)
          end
        # CONFLICT:
        # if expected_yaml.blank?
        #   fetcher.file_storage.write_file("episodes/#{episode.slug}/processed.yaml", actual_yaml)
        # elsif actual_yaml != expected_yaml
        #   fetcher.file_storage.write_file("episodes/#{episode.slug}/processed-actual.yaml", actual_yaml)
          puts
          puts "Expected version:"
          puts expected_yaml.limit_lines(21)
          puts
          puts "Actual version:"
          puts actual_yaml.limit_lines(20)
          puts
          puts "Diff:"
          puts Diffy::Diff.new(expected_yaml, actual_yaml).to_s(:color).limit_lines(20)
          raise "The processed episode for #{episode.slug.inspect} is different from the stored version. Path: #{episode_path.relative_path_from(Rails.root)}"
        end
      end
    end
  end
end
