class Audio < Upload
  def upload_template
    if uploadable_type == 'User'
      'welcome_media'
    else
      super
    end
  end
end