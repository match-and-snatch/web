def transloadit_video_data_params
  Fixtures.transloadit.video
end

def transloadit_audio_data_params
  Fixtures.transloadit.audio
end

def transloadit_photo_data_params
  Fixtures.transloadit.photo
end

def transloadit_document_data_params
  Fixtures.transloadit.document
end

def contacts_info_data_params
  {"contacts_info" => {"website"=>"website", "facebook"=>"facebook", "twitter"=>"twitter", "youtube"=>"youtube", "instagram"=>"instagram", "pinterest"=>"pinterest", "dribble"=>"dribble", "flickr"=>"flicr", "google+"=>"google", "tumblr"=>"tumblr"}, "authenticity_token"=>"aGhP2ee3b945JmH9ZvyeITRQAbCpbPcsxwFwTMDULws=", "id"=>"serg"}
end

def cover_picture_data_params
  Fixtures.transloadit.cover_picture
end

def profile_picture_data_params
  Fixtures.transloadit.profile_picture
end

def welcome_video_data_params
  Fixtures.transloadit.welcome_video
end

def welcome_audio_data_params
  Fixtures.transloadit.welcome_audio
end

def create_video_upload(user)
  UploadManager.new(user).create_pending_video(transloadit_video_data_params)
end

def create_audio_upload(user, create_post: false)
  UploadManager.new(user).create_pending_audios(transloadit_audio_data_params).tap do
    PostManager.new(user: user).create_audio_post(title: 'test', message: 'test') if create_post
  end
end

def create_document_upload(user, _params = {})
  UploadManager.new(user).create_pending_documents(transloadit_document_data_params)
end

def create_photo_upload(user)
  UploadManager.new(user).create_pending_photos(transloadit_photo_data_params)
end
