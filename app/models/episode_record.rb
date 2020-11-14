class EpisodeRecord < ApplicationRecord

  has_many :vocab_slide_records

  def self.upsert!(access_key, data)
    record = find_by(access_key: access_key)
    if record.present?
      record.update!(data: data)
      record
    else
      begin
        create!(
          access_key: access_key,
          data: data,
        )
      rescue ActiveRecord::RecordNotUnique
        find_by(access_key: access_key)
      end
    end
  end

end
