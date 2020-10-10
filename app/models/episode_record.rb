class EpisodeRecord < ApplicationRecord

  def self.upsert!(access_key, data)
    record = find_by(access_key: access_key)
    if record.present?
      record.update!(data: data)
      record
    else
      create!(
        access_key: access_key,
        data: data,
      )
    end
  end

end
