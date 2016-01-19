# @param _params [Hash]
# @return [User]
def create_user(_params = {})
  params = _params.clone.symbolize_keys
  params.reverse_merge! email:                 'serge@gmail.com',
                        password:              'password',
                        password_confirmation: 'password',
                        first_name:            'sergei',
                        last_name:             'zinin',
                        is_profile_owner:      false

  AuthenticationManager.new(params.slice(:is_profile_owner, :email,
                                         :password, :password_confirmation,
                                         :first_name, :last_name)).register.tap do |user|
    if params[:api_token]
      user.api_token = params[:api_token]
    end

    if params[:profile_picture_url]
      user.profile_picture_url = params[:profile_picture_url]
    end

    if params[:itunes_enabled]
      UserProfileManager.new(user).enable_itunes
    end

    user.save! if user.changed?
  end
end

# @param _params [Hash]
# @return [User]
def create_profile(_params = {})
  params = _params.clone
  params.reverse_merge! account_number:   '000123456789',
                        cost:             5,
                        holder_name:      'serg',
                        profile_name:     'serg',
                        routing_number:   '123456789',
                        is_profile_owner: true

  UserProfileManager.new(create_user(params)).send(:update, account_number:    params[:account_number],
                                                            cost:              params[:cost],
                                                            holder_name:       params[:holder_name],
                                                            profile_name:      params[:profile_name],
                                                            routing_number:    params[:routing_number])
end

# @param _params [Hash]
# @return [User]
def create_public_profile(params = {})
  UserProfileManager.new(create_profile(params)).make_profile_public
end

# @param _params [Hash]
# @return [User]
def create_admin(params = {})
  create_user(params).tap do |user|
    UserManager.new(user).make_admin
  end
end

# @param _params [Hash]
# @return [User]
def create_sales(params = {})
  create_user(params).tap do |user|
    UserManager.new(user).make_sales
  end
end

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
