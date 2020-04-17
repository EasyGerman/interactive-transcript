namespace :feed do
  desc "Get information about the whole feed"
  task :stats => :environment do
    total_para_count = 0
    total_text_length = 0
    Feed.new.episodes.map do |episode|
      total_para_count += (ep_para_count = episode.paragraphs.count)
      total_text_length += (ep_text_length = episode.paragraphs.map(&:text).map(&:length).sum)
      puts(
        [
          ("/episodes/#{episode.access_key}" if episode.access_key).to_s.ljust(28),
          ep_para_count.to_s.rjust(3, ' '),
          ep_text_length.to_s.rjust(7, ' '),
          episode.title,
        ].join(" ")
      )
    end
    puts
    puts "Total timestamped paragraphs: #{total_para_count}"
    puts "Total timestamped characters: #{total_text_length}"
  end
end
