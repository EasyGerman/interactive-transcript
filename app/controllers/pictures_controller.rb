class PicturesController < ApplicationController

  def show
    access_key = params[:episode_id].presence or raise "access key missing"
    chapter_key = params[:chapter_id] or raise "chapter key missing"

    # 1. Find Episode
    episode_record = EpisodeRecord.find_by(access_key: access_key)

    if episode_record.blank?
      Rails.logger.warn("Episode #{access_key} not found in database")
      render 'not_found', status: 404
      return
    end

    # 2. Find or create Slide
    slide = episode_record.vocab_slide_records.find_by(chapter_key: chapter_key)

    if slide.blank?
      Rails.logger.info "Slide record not found"

      episode = Feed.new.episodes.find { |ep| ep.access_key == access_key }
      if episode.blank?
        Rails.logger.warn("Episode #{access_key} not found in feed")
        render 'not_found', status: 404
        return
      end

      chapter = episode.audio.chapters.find { |chapter| chapter.id == chapter_key }
      if chapter.blank?
        Rails.logger.warn("Chapter #{chapter_key} not found for episode #{access_key}")
        render 'not_found', status: 404
        return
      end

      slide = episode_record.vocab_slide_records.upsert!(chapter.id, chapter.picture.data)
    end

    # 3. Upload to AWS
    VocabSlide.new(slide, access_key).upload # TODO: episode.vocab_slide (ability to instantiate Episode without parsing the feed)

    # 4. Redirect
    redirect_to current_podcast.vocab_helper_image_access_url(access_key, chapter_key)
  end

end
