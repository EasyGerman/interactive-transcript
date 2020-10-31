require "rails_helper"

describe "Processing", :data do

  fetcher = FsFetcher.new(Rails.root.join('data'))
  feed = Feed.new(fetcher)

  episodes_to_test =
    case ENV['EP']
    when '', nil then []
    when 'l', 'latest' then [feed.episodes.first]
    when 'r', 'rand' then [feed.episodes.sample]
    when 'a', 'all' then feed.episodes
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
