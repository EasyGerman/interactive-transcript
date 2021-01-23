class ContentProvider

  class << self
    def root_path
      Rails.root.join('data')
    end

    def for_podcast(podcast)
      ::ContentProvider::ForPodcast.new(podcast, parent_path: root_path)
    end

    def for_each_podcast
      ::Podcast.all.each do |podcast|
        yield for_podcast(podcast)
      end
    end
  end

end
