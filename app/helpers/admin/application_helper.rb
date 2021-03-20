module Admin::ApplicationHelper
  def rescue_and_show_errors
    yield
    nil
  rescue StandardError => error
    render 'admin/shared/exception', error: error
  end

  alias error_boundary rescue_and_show_errors

  def admin_episodes_path(podcast)
    admin_podcast_episodes_path(podcast.code)
  end

  def admin_episode_path(episode)
    admin_podcast_episode_path(episode.podcast.code, episode.slug)
  end

  def admin_episode_timed_script_path(episode)
    admin_podcast_episode_timed_script_path(episode.podcast.code, episode.slug)
  end

  def admin_paragraph_path(paragraph)
    admin_podcast_episode_paragraph_path(paragraph.episode.podcast.code, paragraph.episode.slug, paragraph.slug)
  end

  def player_path(episode)
    episode_url(episode.access_key, host: episode.podcast.host.sub(/\.fm\Z/, '.local'))
  end

  def render_object(o)
    render partial: "admin/objects/#{o.class.name.underscore}", locals: { o: o }
  end

  def link_to_object(o)
    case o
    when Podcast
      link_to_if_different current_podcast.code, admin_podcast_path(current_podcast.code)
    when Episode
      link_to_if_different "Episodes", admin_episode_path(current_podcast.code)
    else
      raise "Don't know how to render link to #{o.class.name}"
    end
  end

  def breadcrumb_connector
    '&nbsp; ▸ &nbsp;'.html_safe
  end

  def breadcrumbs(*args)
    content_tag 'nav', id: 'breadcrumbs' do
      breadcrumbs_to(*args).join(breadcrumb_connector).html_safe
    end
  end

  def breadcrumbs_to(o, last_element = nil)
    case o
    when :root
      [
        link_to_if_different("Admin", admin_root_path)
      ]
    when Podcast
      [
        *breadcrumbs_to(:root),
        link_to_object(o),
        (
          case last_element
          when :episodes
            link_to_if_different("Episodes", admin_podcast_episodes_path(o.code))
          end
        )
      ].compact
    when Episode
      [
        *breadcrumbs_to(o.podcast, :episodes),
        link_to_if_different(o.title, admin_episode_path(o)),
        (
          case last_element
          when :timed_script
            link_to_if_different("Timed Script", admin_podcast_episode_timed_script_path(o.podcast.code, o.slug))
          end
        )
      ].compact
    else
      raise "Don't know how to render link to #{o.class.name}"
    end
  end

  def link_to_if_different(label, href)
    if request.path == href
      label
    else
      link_to(label, href)
    end
  end
end
