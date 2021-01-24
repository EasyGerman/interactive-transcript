Podcast.all.each do |podcast|
  define_method podcast.code do
    podcast
  end
end
