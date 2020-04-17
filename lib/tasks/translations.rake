namespace :translations do
  desc "Translate all paragraphs in the transcripts"
  task :prepopulate => :environment do
    translated_paras = 0
    translated_chars = 0
    begin
      Feed.new.episodes.map do |episode|
        puts "#{episode.title} #{episode.access_key}"
        if episode.access_key
          print "Translating #{episode.paragraphs.count} paragraphs"
          episode.paragraphs.each do |paragraph|
            print "."
            Translator.translate(paragraph.text, "en")
            translated_paras += 1
            translated_chars += paragraph.text.length
          end
          puts
        end
      end
    ensure
      puts "\nTranslated #{translated_chars} characters across #{translated_paras} paragraphs."
    end
  end
end
