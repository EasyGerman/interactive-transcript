namespace :enhanced_transcript do
  desc "Parse a transcript exported from the transcript editor"
  task :parse => :environment do
    slug = "28-in-bonus-35983611"
    transcript_editor_html = File.read(Rails.root.join("data", "episodes", slug, "transcript_editor.html"))

    t = Transcript.new(transcript_editor_html)
    t.analyze
  end
end
