module AwsUtils

  REGION = ENV.fetch('AWS_REGION', 'eu-central-1')
  BUCKET = ENV.fetch('AWS_BUCKET', 'easygermanpodcastplayer-public')

  def upload_to_aws(path, data)
    Rails.logger.info "Uploading #{path} (#{data.size} bytes)"
    file = Tempfile.new(encoding: 'ascii-8bit')
    begin
      file.write(data)
      file.rewind

      object = Aws::S3::Resource.new(region: REGION).bucket(BUCKET).object(path)
      object.upload_file(file.path)

      Rails.logger.info "Finished uploading #{path}"
    rescue => e
      Rails.logger.error "Failed uploading #{path}: #{e.class.name} #{e.message} #{e.backtrace.first}"
    ensure
      file.close
      file.unlink
    end
  end
end
