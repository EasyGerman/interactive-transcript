##
# Entities that represent a processed episode and can be cached and passed to the view for rendering.
#
module Processed
  class Timestamp < CustomStruct
    attribute :text, Types::String
    attribute :seconds, Types::Integer
  end

  class Segment < CustomStruct
    attribute :timestamp, Timestamp
    attribute :text, Types::String
  end

  class Speaker < CustomStruct
    attribute :name, Types::String
  end

  class Paragraph < CustomStruct
    attribute :translation_id, Types::String
    attribute :slug, Types::String
    attribute :speaker, Speaker.optional
    attribute :timestamp, Timestamp.optional
    attribute :segments, Types::Array.of(Segment).optional
    attribute :text, Types::String
  end

  class Chapter < CustomStruct
    attribute :title, Types::String.optional
    attribute :paragraphs, Types::Array.of(Paragraph)
  end

  class AudioChapter < CustomStruct
    attribute :id, Types::String
    attribute :start_time, Types::Integer
    attribute :end_time, Types::Integer
    attribute :has_picture, Types::Bool
  end

  class Episode < CustomStruct
    attribute :title, Types::String
    attribute :cover_url, Types::String
    attribute :audio_url, Types::String
    attribute :notes_html, Types::String
    attribute :chapters, Types::Array.of(Chapter).optional
    attribute :audio_chapters, Types::Array.of(AudioChapter).optional
  end
end
