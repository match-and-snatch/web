class Upload < ActiveRecord::Base
  self.inheritance_column = nil
  serialize :transloadit_data, Hash
  belongs_to :uploadable, polymorphic: true

  scope :pending, -> { where uploadable_id: nil }
  scope :posts, -> { where uploadable_type: 'Post' }

  # @param step_name [String, Symbol] See transloadit.yml
  # @return [String, nil]
  def url_on_step(step_name)
    attr_on_step(step_name, 'url')
  end

  def attr_on_step(step_name, attribute)
    if results = transloadit_data['results']
      if step = results[step_name].try(:first)
        return step[attribute.to_s]
      end
    end
  end

  def secure_url_on_step(step_name, expiration_date = 30.minutes.from_now.utc.to_i)
    url = attr_on_step(step_name, 'url')
    key, secret, bucket = Transloadit::Rails::Engine.configuration["templates"]['post_video']['steps']['store'].slice("key", "secret", "bucket").values
    s3_base_url       = "http://#{URI(url).host}"
    s3_path = URI(url).path
    # this needs to be formatted exactly as shown below and UTF-8 encoded
    string_to_sign = "GET\n\n\n#{expiration_date}\n/#{bucket}#{s3_path}".encode("UTF-8")

    signature = CGI.escape( Base64.encode64(
                              OpenSSL::HMAC.digest(
                                OpenSSL::Digest::Digest.new('sha1'),
                                  secret, string_to_sign)).gsub("\n","") )
    "#{s3_base_url}#{s3_path}?AWSAccessKeyId=#{key}&Expires=#{expiration_date}&Signature=#{signature}"
  end

  def video?
    'video' == type
  end

  def image?
    'image' == type
  end

end
