class UploadManager < BaseManager
  attr_reader :user

  # @param user [User]
  def initialize(user)
    @user = user
  end

  def reorder(ids)
    ids.each_with_index do |id, index|
      user.source_uploads.where(id: id).update_all(ordering: index)
    end
  end

  # @param transloadit_data [Hash]
  # @return [Array<Upload>]
  def create_pending_audios(transloadit_data)
    transloadit_data['uploads']                       or fail_with! 'Nothing uploaded'
    transloadit_data['uploads'][0]                    or fail_with! 'No uploads'
    transloadit_data['uploads'][0]['type'] == 'audio' or fail_with! 'Uploaded file is not an audio'

    if AudioPost.pending_uploads_for(user).count > 15
      fail_with! "You can't upload more than 15 tracks."
    end

    attributes = { uploadable_type: 'Post', uploadable_id: nil }

    transloadit_data['uploads'].each_with_index.map do |upload_data, index|
      original = transloadit_data['results'][':original'][index]
      # TODO: fetch track name
      upload = Audio.new transloadit_data: transloadit_data,
                         user_id:          user.id,
                         type:             'Audio',
                         duration:         upload_data['meta']['duration'],
                         mime_type:        upload_data['mime'],
                         filename:         upload_data['name'],
                         filesize:         upload_data['size'],
                         basename:         upload_data['basename'],
                         url:              original['ssl_url']
      upload.attributes = attributes
      upload.save or fail_with! upload.errors
      upload
    end
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
    create_video(transloadit_data, attributes: { uploadable_type: 'Post',
                                                 uploadable_id: nil,
                                                 preview_url: thumb['ssl_url'] })
  end

  # @param transloadit_data [Hash]
  # @return [Array<Upload>]
  def create_pending_photos(transloadit_data)
    attributes = { uploadable_type: 'Post', uploadable_id: nil }

    transloadit_data['uploads'].each_with_index.map do |upload_data, index|
      transloadit_data['results']['preview']   or fail_with! 'Invalid image'
      transloadit_data['results'][':original'] or fail_with! 'Invalid image'

      original = transloadit_data['results'][':original'][index]
      preview  = transloadit_data['results']['preview'][index]
      upload = Photo.new transloadit_data: transloadit_data,
                         user_id:          user.id,
                         type:             'Photo',
                         duration:         upload_data['meta']['duration'],
                         mime_type:        upload_data['mime'],
                         filename:         upload_data['name'],
                         filesize:         upload_data['size'],
                         width:            upload_data['meta']['width'],
                         height:           upload_data['meta']['height'],
                         url:              original['ssl_url']
      upload.attributes = attributes.merge(preview_url: preview['ssl_url'])
      upload.save or fail_with! upload.errors
      upload
    end
  end

  # @param transloadit_data [Hash]
  # @return [Array<Upload>]
  def create_pending_documents(transloadit_data)
    if DocumentPost.pending_uploads_for(user).count >= 5
      fail_with! "You can't upload more than 5 documents."
    end

    attributes = { uploadable_type: 'Post', uploadable_id: nil }

    transloadit_data['uploads'].each_with_index.map do |upload_data, index|
      original = transloadit_data['results'][':original'][index]
      if transloadit_data['results']['preview']
        preview  = transloadit_data['results']['preview'][index]
      end
      upload = Document.new transloadit_data: transloadit_data,
                            user_id:          user.id,
                            type:             'Document',
                            duration:         upload_data['meta']['duration'],
                            mime_type:        upload_data['mime'],
                            filename:         upload_data['name'],
                            filesize:         upload_data['size'],
                            basename:         upload_data['basename'],
                            width:            upload_data['meta']['width'],
                            height:           upload_data['meta']['height'],
                            url:              original['ssl_url']
      if preview
        upload.attributes = attributes.merge(preview_url: preview['ssl_url'])
      else
        upload.attributes = attributes
      end
      upload.save or fail_with! upload.errors
      upload
    end
  end

  # @param transloadit_data [Hash]
  # @param uploadable [ActiveRecord::Base]
  # @param attributes [Hash] upload attributes
  # @return [Upload]
  def create_photo(transloadit_data, uploadable: user, attributes: {})
    upload = Photo.new transloadit_data: transloadit_data,
                       uploadable: uploadable,
                       user_id: user.id,
                       duration: transloadit_data["uploads"][0]["meta"]["duration"],
                       mime_type: transloadit_data["uploads"][0]["mime"],
                       filename: transloadit_data["uploads"][0]['name'],
                       filesize: transloadit_data["uploads"][0]['size'],
                       basename: transloadit_data["uploads"][0]['basename'],
                       width: transloadit_data["uploads"][0]["meta"]["width"],
                       height: transloadit_data["uploads"][0]["meta"]["height"],
                       url: transloadit_data["results"][":original"][0]["ssl_url"]
    upload.attributes = attributes
    upload.save or fail_with! upload.errors
    upload
  end

  private

  # @param transloadit_data [Hash]
  # @param uploadable [ActiveRecord::Base]
  # @param attributes [Hash] upload attributes
  # @return [Upload]
  def create_video(transloadit_data, uploadable: user, attributes: {})
    upload = Video.new transloadit_data: transloadit_data,
                       uploadable: uploadable,
                       user_id: user.id,
                       type: 'Video',
                       duration: transloadit_data["uploads"][0]["meta"]["duration"],
                       mime_type: transloadit_data["uploads"][0]["mime"],
                       filename: transloadit_data["uploads"][0]['name'],
                       filesize: transloadit_data["uploads"][0]['size'],
                       basename: transloadit_data["uploads"][0]['basename'],
                       width: transloadit_data["uploads"][0]["meta"]["width"],
                       height: transloadit_data["uploads"][0]["meta"]["height"],
                       url: transloadit_data["results"]["encode"][0]["ssl_url"]
    upload.attributes = attributes
    upload.save or fail_with! upload.errors
    upload
  end
end
