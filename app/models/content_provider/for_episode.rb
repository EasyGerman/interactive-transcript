class ContentProvider
  class ForEpisode
    include ::ContentProvider::LocalCacheMethods

    attr_reader :episode, :parent_path

    def initialize(episode, parent_path:)
      @episode = episode
      @parent_path = parent_path
    end

    def root_path
      parent_path.join('episodes', episode.slug)
    end

    # ---------- audio ----------

    def path_to_audio
      root_path.join('audio.mp3')
    end

    def fetch_audio
      with_local_cache(path_to_audio) do
        NetworkUtils.get(episode.audio_url)
      end
    end

    # ---------- downloadable transcript ----------

    def path_to_downloadable_transcript
      root_path.join('downloadable.html')
    end

    def fetch_downloadable_transcript
      with_local_cache(path_to_downloadable_transcript) do
        open(episode.downloadable_html_url) do |io|
          io.set_encoding('UTF-8')
          io.read
        end
      end
    end

    # ---------- editor transcript ----------

    def path_to_editor_transcript
      root_path.join('editor.html')
    end

    def fetch_editor_transcript
      with_local_cache(path_to_editor_transcript) do
        editor_transcript_config = episode.podcast.editor_transcript_config

        file_contents =
          DropboxAdapter.new(
            editor_transcript_config["dropbox_access_key"],
            editor_transcript_config["dropbox_shared_link"],
          ).transcript_for(episode.short_name)

        file_contents
      end
    end

    # ---------- processed ----------

    def path_to_processed_yaml
      root_path.join('processed.yaml')
    end

    def fetch_processed_yaml
      File.read(path_to_processed_yaml)
    end

    # ---------- file utils ----------

    def write_file(path, content)
      path = root_path.join(path) if path.is_a?(String)
      FileUtils.mkdir_p(path.join('..'))
      File.open(path, 'w') { |f| f.write(content) }
    end
  end
end
