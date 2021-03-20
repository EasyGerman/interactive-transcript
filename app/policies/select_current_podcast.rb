class SelectCurrentPodcast < Operation

  attribute :host, Types::String
  attribute :code, Types::String.optional
  attribute :env, Types::String.enum('development', 'test', 'production')
  attribute :podcasts, Types::Array.of(Types.Interface(:host, :code))

  def call
    find_by_host ||
      find_in_development ||
      raise("Podcast not found")
  end

  def find_by_host
    podcasts.find { |podcast| podcast.host == host }
  end

  def find_in_development
    if env.in?(['development', 'test'])
      find_by_development_host || find_by_code
    end
  end

  def find_by_development_host
    normalized_host = host.sub(/\.local\Z/, '.fm')
    podcasts.find { |podcast| podcast.host == normalized_host }
  end

  def find_by_code
    podcasts.find { |podcast| podcast.code == code }
  end

end
