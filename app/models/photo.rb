class Photo < Upload
  def upload_template
    if uploadable_type == 'User'
      'profile_image'
    else
      super
    end
  end

  def bucket
    if uploadable_type == 'User'
      Transloadit::Rails::Engine.configuration['profile_image']['bucket']
    else
      super
    end
  end
end