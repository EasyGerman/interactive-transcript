class VocabSlide
  include AwsUtils

  attr_reader :record, :episode_access_key

  def initialize(record, episode_access_key)
    @record = record
    @episode_access_key = episode_access_key
  end

  def upload
    upload_to_aws("vocab/#{episode_access_key}/#{record.chapter_key}.jpg", record.data)
    record.touch(:uploaded_at)
  end

end
