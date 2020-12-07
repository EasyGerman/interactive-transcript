class PodcastNotFound < StandardError

  attr_reader :host

  def initialize(host)
    @host = host
    super("Podcast not found: #{host}")
  end

end
