class Upload < ApplicationRecord
  serialize :transloadit_data, Hash
  serialize :s3_paths, Hash
  belongs_to :uploadable, polymorphic: true
  belongs_to :user

  scope :pending,   -> { where uploadable_id: nil }
  scope :posts,     -> { where uploadable_type: 'Post' }
  scope :users,     -> { where uploadable_type: 'User' }
  scope :photos,    -> { where type: 'Photo' }
  scope :audios,    -> { where type: 'Audio' }
  scope :videos,    -> { where type: 'Video' }
  scope :documents, -> { where type: 'Document' }
  scope :ordered,   -> { order('ordering, id') }
  scope :not_removed, -> { where(removed: false) }

  # @return [String]
  def file_type
    mime_type.split('/').last
  end

  # @param step_name [String, Symbol] See transloadit.yml
  # @return [String, nil]
  def url_on_step(step_name)
    attr_on_step(step_name, 'ssl_url')
  end

  def attr_on_step(step_name, attribute)
    if results = transloadit_data['results']
      if step = results[step_name].try(:first)
        return step[attribute.to_s]
      end
    end
  end

  def original_url
    return if url.blank?
    host = APP_CONFIG['media_host']
    path = URI(url).path
    "https://#{host}#{path}"
  end

  def rtmp_path(video_url: url)
    return if video_url.blank?
    uri = URI(video_url)
    host = uri.host
    path = uri.path
    "rtmp://#{host}/cfx/st#{path}"
  end

  def hd_rtmp_path
    rtmp_path(video_url: hd_url)
  end

  def secure_url
    generate_secure_url(url)
  end

  def secure_preview_url
    generate_secure_url(preview_url)
  end

  def video?
    'Video' == type
  end

  def image?
    'Image' == type
  end

  def document?
    'Document' == type
  end

  def delete_s3_files!
    errors = []
    s3_paths.each do |bucket, paths|
      errors << s3_client.delete_objects(bucket: bucket, delete: {objects: paths, quiet: false})['errors']
    end
    if errors.flatten.blank?
      self.removed = true
      self.removed_at = Time.zone.now
      self.save!
    end
  end

  private

  def generate_secure_url(upload_url, expiration_date = 30.minutes.from_now.utc.to_i)
    key, secret, bucket = Transloadit::Rails::Engine.configuration['_templates']['post_video']['steps']['store'].slice('key', 'secret', 'bucket').values
    s3_base_url = "//#{URI(upload_url).host}"
    s3_path = URI(upload_url).path
    # this needs to be formatted exactly as shown below and UTF-8 encoded
    string_to_sign = "GET\n\n\n#{expiration_date}\n/#{bucket}#{s3_path}".encode("UTF-8")
    signature = CGI.escape( Base64.encode64(
                              OpenSSL::HMAC.digest(
                                OpenSSL::Digest::Digest.new('sha1'),
                                  secret, string_to_sign)).gsub("\n","") )
    "#{s3_base_url}#{s3_path}?AWSAccessKeyId=#{key}&Expires=#{expiration_date}&Signature=#{signature}"
  end

  def s3_client
    @s3_client ||= Aws::S3::Client.new(endpoint: 'https://s3.amazonaws.com')
  end
end
