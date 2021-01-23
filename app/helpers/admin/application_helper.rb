module Admin::ApplicationHelper
  def admin_episode_path(episode)
    admin_podcast_episode_path(episode.podcast.code, episode.slug)
  end

  def admin_episode_timed_script_path(episode)
    admin_podcast_episode_timed_script_path(episode.podcast.code, episode.slug)
  end

  def admin_paragraph_path(paragraph)
    admin_podcast_episode_paragraph_path(paragraph.episode.podcast.code, paragraph.episode.slug, paragraph.slug)
  end

  def render_object(o)
    render partial: "admin/objects/#{o.class.name.underscore}", locals: { o: o }
  end
end
