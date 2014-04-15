class UploadManager < BaseManager
  attr_reader :user

  # @param user [User]
  def initialize(user)
    @user = user
  end

  # @param transloadit_data [Hash]
  # @return [Upload]
  def create_pending_video(transloadit_data)
    transloadit_data['uploads']                       or fail_with! 'Nothing uploaded'
    transloadit_data['uploads'][0]                    or fail_with! 'No uploads'
    transloadit_data['uploads'][0]['type'] == 'video' or fail_with! 'Uploaded file is not a video'

    if VideoPost.pending_uploads_for(user).any?
      fail_with! "You can't upload more than one video."
    end

    thumb = transloadit_data['results']['thumbs'].try(:first) or fail_with! 'No thumb received'
    create(transloadit_data, attributes: { uploadable_type: 'Post',
                                           uploadable_id: nil,
                                           preview_url: thumb['url'] })
  end

  # @param transloadit_data [Hash]
  # @return [Array<Upload>]
  def create_pending_photos(transloadit_data)
    attributes = { uploadable_type: 'Post', uploadable_id: nil }

    transloadit_data['uploads'].each_with_index.map do |upload_data, index|
      original = transloadit_data['results'][':original'][index]
      upload = Upload.new transloadit_data: transloadit_data,
                          user_id:          user.id,
                          type:             upload_data['type'],
                          duration:         upload_data['meta']['duration'],
                          mime_type:        upload_data['mime'],
                          width:            upload_data['meta']['width'],
                          height:           upload_data['meta']['height'],
                          url:              original['url']
      upload.attributes = attributes.merge(preview_url: original['url'])
      upload.save or fail_with! upload.errors
      upload
    end
  end

  private

  # @param transloadit_data [Hash]
  # @param uploadable [ActiveRecord::Base]
  # @param attributes [Hash] upload attributes
  # @return [Upload]
  def create(transloadit_data, uploadable: user, attributes: {})
    upload = Upload.new transloadit_data: transloadit_data,
                        uploadable: uploadable,
                        user_id: user.id,
                        type: transloadit_data["uploads"][0]["type"],
                        duration: transloadit_data["uploads"][0]["meta"]["duration"],
                        mime_type: transloadit_data["uploads"][0]["mime"],
                        width: transloadit_data["uploads"][0]["meta"]["width"],
                        height: transloadit_data["uploads"][0]["meta"]["height"],
                        url: transloadit_data["results"][":original"][0]["url"]
    upload.attributes = attributes
    upload.save or fail_with! upload.errors
    upload
  end
end