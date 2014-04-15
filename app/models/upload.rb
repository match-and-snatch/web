class Upload < ActiveRecord::Base
  serialize :transloadit_data, Hash
  belongs_to :uploadable, polymorphic: true

  scope :pending,   -> { where uploadable_id: nil }
  scope :posts,     -> { where uploadable_type: 'Post' }
  scope :photos,    -> { where type: 'Photo' }
  scope :videos,    -> { where type: 'Video' }
  scope :documents, -> { where type: 'Document' }

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

  private
    def generate_secure_url(upload_url, expiration_date = 30.minutes.from_now.utc.to_i)
      key, secret, bucket = Transloadit::Rails::Engine.configuration["templates"]['post_video']['steps']['store'].slice("key", "secret", "bucket").values
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


end
