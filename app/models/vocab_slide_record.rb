class VocabSlideRecord < ApplicationRecord

  belongs_to :episode_record

  def self.upsert!(chapter_key, data)
    create!(chapter_key: chapter_key, data: data)
  rescue ActiveRecord::RecordNotUnique
    find_by!(chapter_key: chapter_key)
  end

end
