ActiveAdmin.register Podcast do
  menu priority: 1
  permit_params :code, :name, :lang, :host, :feed_url,
    :homepage_url, :membership_url, :transcript_title, :header_tags,
    :word_highlighting_enabled, :editor_transcript_dropbox_access_key, :editor_transcript_dropbox_shared_link,
    :vocab_helper_enabled,
    :translations_enabled, :translations_languages, :google_credentials

  index do
    selectable_column
    id_column
    column :code
    column :name do |podcast|
      link_to podcast.name, activeadmin_podcast_path(podcast)
    end
    column :lang
    column :host
    column :feed_url
    actions
  end

  filter :code
  filter :name
  filter :lang
  filter :host

  show do
    attributes_table do
      row :code
      row :name
      row :lang
      row :host
      row :episodes do |podcast|
        link_to pluralize(podcast.episodes.count, "episode"), activeadmin_episodes_path(q: { podcast_id_eq: podcast.id })
      end
      row :settings do |podcast|
        pre JSON.pretty_generate podcast.settings
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input :code, hint: "Short lowercase code that will be used in filenames, URLs. E.g: 'easygerman'."
      f.input :name, hint: "The title of the podcast. E.g: 'The Easy German Podcast'"
      f.input :lang, hint: "2-letter language code of the podcast."
      f.input :host, hint: "The Transcript Player hostname for this podcast. E.g: 'play.easygerman.fm'."
      f.input :feed_url, hint: "The RSS feed for this podcast."

      f.input :homepage_url, hint: "The homepage of this podcast. E.g. 'https://easygerman.fm/'. It will be shown below the title of each episode."
      f.input :membership_url, hint: "The page where users can become a member. People will be redirected here if they navigate to the homepage."
      f.input :transcript_title, hint: "Transcript Player will search for this header in the show notes to find the place where the transcript begins."
      f.input :header_tags, hint: "JSON array of HTML tag names. Transcript Player will look for this one of these tags when searching for the beginning of the transcript. E.g. '[\"h3\"]' or '[\"h2\",\"h3\"]'.", input_html: { value: resource.header_tags.to_json }

      f.input :word_highlighting_enabled, as: :boolean, hint: "The 'Transcript in Editor Mode' files are provided in Dropbox. This influences some styling."
      f.input :editor_transcript_dropbox_access_key, hint: "The Dropbox Access Key for accessing the Shared Link."
      f.input :editor_transcript_dropbox_shared_link, hint: "The Dropbox Shared Link where the 'Transcript in Editor Mode' files are located."

      f.input :vocab_helper_enabled, as: :boolean, hint: "Vocab helper slides are provided in the mp3 file. This influences whether the vocab helper button is shown, plus the layout."

      f.input :translations_enabled, as: :boolean, hint: "Whether this podcast will allow listeners to get automated translations of paragraphs."
      f.input :translations_languages, hint: "Comma-separated 2-letter language codes to be used as target languages for translations. The podcast language will be ignored."
      f.input :google_credentials, as: :text, input_html: { value: JSON.pretty_generate(resource.google_credentials) }
    end
    f.actions

    pre JSON.pretty_generate(resource.settings)
  end

end
