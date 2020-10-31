require "rails_helper"

describe "Processing", :data do

  fetcher = FsFetcher.new(Rails.root.join('data'))
  feed = Feed.new(fetcher)

  episodes_to_test =
    case ENV['EP']
    when '', nil then []
    when 'l', 'latest' then [feed.episodes.first]
    when /^l(\d+)$/ then feed.episodes.first($1.to_i)
    when 'r', 'rand' then [feed.episodes.sample]
    when /^r(\d+)$/ then feed.episodes.sample($1.to_i)
    when 'a', 'all' then feed.episodes
    when /^(\d+)$/ then feed.episodes.select { |e| e.number == $1.to_i }
    when /^(\d+)..(\d+)$/ then feed.episodes.select { |e| e.number >= $1.to_i && e.number <= $2.to_i }
    else raise "Unrecognized EP=#{ENV['EP']}"
    end

  episodes_to_test.each do |episode|
    if episode.transcript.present?
      it "processes episode '#{episode.slug}' correctly" do
        actual_yaml = YAML.dump(episode.processed.as_json)
        expected_yaml = fetcher.fetch_processed_yaml(episode)
        expect(actual_yaml).to eq expected_yaml
      end
    end
  end

end
