class Video < Upload
  def upload_template
    if uploadable_type == 'User'
      'welcome_media'
    else
      super
    end
  end

  def delete_s3_files!
    super
    thumbs_bucket = Transloadit::Rails::Engine.configuration['templates'][upload_template]['steps']['s3_thumb']['bucket']
    objects = transloadit_data['results']['thumbs'].map { |h| { key: URI(h['url']).path.sub('/', '') } }.flatten
    s3_client.delete_objects(bucket: thumbs_bucket, delete: { objects: objects, quiet: true })
  end
end