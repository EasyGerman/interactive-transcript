require "rails_helper"

describe "Processing", :data, vcr: false do

  podcasts =
    if podcast_specifier = ENV['PODCAST'].presence
      [Podcast.find_by!(code: podcast_specifier)]
    else
      Podcast.all.to_a
    end

  podcasts.each do |podcast|
    fetcher = FsFetcher.new(podcast)
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
      if episode.transcript.present?
        it "processes episode '#{episode.slug}' correctly" do
          actual_yaml = YAML.dump(episode.processed.as_json)
          expected_yaml =
            begin
              fetcher.fetch_processed_yaml(episode)
            rescue Errno::ENOENT
              nil
            end

          if expected_yaml.blank?
            fetcher.file_storage.write_file("episodes/#{episode.slug}/processed.yaml", actual_yaml)
          elsif actual_yaml != expected_yaml
            fetcher.file_storage.write_file("episodes/#{episode.slug}/processed-actual.yaml", actual_yaml)
            puts
            puts "Expected version:"
            puts expected_yaml.limit_lines(20)
            puts
            puts "Actual version:"
            puts actual_yaml.limit_lines(20)
            puts
            puts "Diff:"
            puts Diffy::Diff.new(expected_yaml, actual_yaml).to_s(:color).limit_lines(20)
            raise "the processed episode is different from the stored version"
          end
        end
      end
    end
  end


end
