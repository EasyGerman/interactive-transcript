module Processor
  module Public
    module Methods
      def process_episode(podcast, access_key)
        ProcessEpisode.(podcast: podcast, access_key: access_key)
      end
    end
  end
end