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
    # transloadit_data['uploads'][0]['type'] == 'audio' or fail_with! 'Uploaded file is not an audio' NOTE(SZ): condition fails with m4a

    if AudioPost.pending_uploads_for(user).count > 15
      fail_with! "You can't upload more than 15 tracks."
    end

    create_audio(transloadit_data, template: 'post_audio', attributes: { uploadable_type: 'Post',
                                                                         uploadable_id: nil })
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

    create_video(transloadit_data, template: 'post_video', attributes: { uploadable_type: 'Post',
                                                                         uploadable_id: nil })
  end

  def create_pending_video_previews(transloadit_data)
    transloadit_data['results']['full_size'] or fail_with! 'Invalid transloadit data'

    bucket = Transloadit::Rails::Engine.configuration['templates']['post_video']['steps']['s3_thumb']['bucket']

    transloadit_data['uploads'].each.map do |upload_data|
      original_id = upload_data['original_id']
      original = search_related_result(transloadit_data['results']['full_size'], original_id)

      if original
        s3_paths = { bucket => [original['ssl_url']].map { |e| { key: get_file_path(e) } } }

        upload = PendingVideoPreviewPhoto.new transloadit_data: transloadit_data.to_hash,
                                              s3_paths:         s3_paths,
                                              uploadable_type: 'Video',
                                              user_id:          user.id,
                                              mime_type:        upload_data['mime'],
                                              filename:         upload_data['name'],
                                              filesize:         upload_data['size'],
                                              basename:         upload_data['basename'],
                                              width:            upload_data['meta']['width'],
                                              height:           upload_data['meta']['height'],
                                              url:              original['ssl_url']

        save_or_die! upload
        EventsManager.file_uploaded(user: user, file: upload)
        upload
      end
    end
  end

  # @param transloadit_data [Hash]
  # @return [Array<Upload>]
  def create_pending_photos(transloadit_data)
    transloadit_data['results']['preview']   or fail_with! 'Invalid transloadit data'
    transloadit_data['results']['full_size'] or fail_with! 'Invalid transloadit data'

    attributes = { uploadable_type: 'Post', uploadable_id: nil }
    bucket = Transloadit::Rails::Engine.configuration['templates']['post_photo']['steps']['store']['bucket']

    transloadit_data['uploads'].each.map do |upload_data|
      original_id = upload_data['original_id']
      original = search_related_result(transloadit_data['results']['full_size'], original_id)

      if original
        preview = search_related_result(transloadit_data['results']['preview'], original_id)

        s3_paths = { bucket => [original['ssl_url'], preview['ssl_url']].map { |e| { key: get_file_path(e) } } }

        upload = Photo.new transloadit_data: transloadit_data.to_hash,
                           s3_paths:         s3_paths,
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
        save_or_die! upload
        EventsManager.file_uploaded(user: user, file: upload)
        upload
      end
    end
  end

  # @param transloadit_data [Hash]
  # @return [Array<Upload>]
  def create_pending_documents(transloadit_data)
    if DocumentPost.pending_uploads_for(user).count >= 5
      fail_with! "You can't upload more than 5 documents."
    end

    attributes = { uploadable_type: 'Post', uploadable_id: nil }
    bucket = Transloadit::Rails::Engine.configuration['templates']['post_document']['steps']['store']['bucket']

    transloadit_data['uploads'].each.map do |upload_data|
      original_id = upload_data['original_id']
      original = search_related_result(transloadit_data['results'][':original'], original_id)

      if original
        s3_paths = { bucket => [{ key: get_file_path(original['ssl_url']) }]}

        if transloadit_data['results']['preview']
          preview = search_related_result(transloadit_data['results']['preview'], original_id)
          s3_paths[bucket] << { key: get_file_path(preview['ssl_url']) }
        end

        upload = Document.new transloadit_data: transloadit_data.to_hash,
                              s3_paths:         s3_paths,
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
        save_or_die! upload
        EventsManager.file_uploaded(user: user, file: upload)
        upload
      end
    end
  end

  # @param transloadit_data [Hash]
  # @param uploadable [ActiveRecord::Base]
  # @param attributes [Hash] upload attributes
  # @return [Upload]
  def create_photo(transloadit_data, uploadable: user, template: 'post_photo', attributes: {})
    bucket = Transloadit::Rails::Engine.configuration['templates'][template]['steps']['store']['bucket']

    s3_paths = { bucket => [] }
    Transloadit::Rails::Engine.configuration['templates'][template]['steps']['store']['use'].each do |key|
      s3_paths[bucket] << { key: get_file_path(transloadit_data['results'][key][0]['ssl_url']) }
    end

    upload = Photo.new transloadit_data: transloadit_data.to_hash,
                       s3_paths:         s3_paths,
                       uploadable:       uploadable,
                       user_id:          user.id,
                       duration:         transloadit_data['uploads'][0]['meta']['duration'],
                       mime_type:        transloadit_data['uploads'][0]['mime'],
                       filename:         transloadit_data['uploads'][0]['name'],
                       filesize:         transloadit_data['uploads'][0]['size'],
                       basename:         transloadit_data['uploads'][0]['basename'],
                       width:            transloadit_data['uploads'][0]['meta']['width'],
                       height:           transloadit_data['uploads'][0]['meta']['height'],
                       url:              transloadit_data['results'][':original'][0]['ssl_url']
    upload.attributes = attributes
    save_or_die! upload
    EventsManager.file_uploaded(user: user, file: upload)
    upload
  end

  # @param transloadit_data [Hash]
  # @param uploadable [ActiveRecord::Base]
  # @param attributes [Hash] upload attributes
  # @return [Upload]
  def create_video(transloadit_data, uploadable: user, template: 'post_video', attributes: {})
    #thumb = transloadit_data['results']['thumbs'].try(:first) or fail_with! 'No thumb received'
    thumbs = transloadit_data['results']['thumbs'].presence or fail_with! 'No thumb received'
    thumb = thumbs.first
    encode = transloadit_data['results']['encode'][0]

    #hd_step = transloadit_data['results']['encode_hd']
    #encode_hd = hd_step[0] if hd_step

    #playlist = transloadit_data['results']['playlist'].try(:[], 0) || {}
    #low_playlist = transloadit_data['results']['low_playlist'][0]
    #high_playlist = transloadit_data['results']['high_playlist'].try(:[], 0) || {}

    original = transloadit_data['results'][':original'][0]

    #hd_url = encode_hd['ssl_url'] if encode_hd

    preview_bucket = Transloadit::Rails::Engine.configuration['templates'][template]['steps']['s3_thumb']['bucket']
    videos_bucket  = Transloadit::Rails::Engine.configuration['templates'][template]['steps']['store_low']['bucket']

    s3_paths = { videos_bucket  => [encode['ssl_url'], original['ssl_url']].compact.map { |e| { key: get_file_path(e) } } }

    upload = Video.new transloadit_data: transloadit_data.to_hash,
                       s3_paths:         s3_paths,
                       uploadable:       uploadable,
                       user_id:          user.id,
                       type:             'Video',
                       duration:         transloadit_data['uploads'][0]['meta']['duration'],
                       mime_type:        transloadit_data['uploads'][0]['mime'],
                       filename:         transloadit_data['uploads'][0]['name'],
                       filesize:         transloadit_data['uploads'][0]['size'],
                       basename:         transloadit_data['uploads'][0]['basename'],
                       width:            transloadit_data['uploads'][0]['meta']['width'],
                       height:           transloadit_data['uploads'][0]['meta']['height'],
                       url:              encode['ssl_url'],
                       preview_url:      thumb['ssl_url']
                       #playlist_url:     playlist['ssl_url'],
                       #low_quality_playlist_url: low_playlist['ssl_url'],
                       #high_quality_playlist_url: high_playlist['ssl_url'], # TODO: Change ssl_url to url?
                       #hd_url:           hd_url,
    upload.attributes = attributes
    save_or_die! upload

    user.pending_video_preview_photos.each(&:destroy)
    thumbs.each do |thumb|
      preview = PendingVideoPreviewPhoto.new transloadit_data: thumb.to_hash,
                                             s3_paths:   {preview_bucket => {key: get_file_path(thumb['ssl_url'])}},
                                             uploadable_type: 'Video',
                                             user_id:    user.id,
                                             mime_type:  thumb['mime'],
                                             filename:   thumb['name'],
                                             filesize:   thumb['size'],
                                             basename:   thumb['basename'],
                                             width:      thumb['meta']['width'],
                                             height:     thumb['meta']['height'],
                                             url:        thumb['ssl_url']
      preview.save!
    end

    EventsManager.file_uploaded(user: user, file: upload)
    upload
  end

  # @param transloadit_data [Hash]
  # @param uploadable [ActiveRecord::Base]
  # @param attributes [Hash] upload attributes
  # @return [Array<Upload>]
  def create_audio(transloadit_data, uploadable: user, template: 'post_audio', attributes: {})
    steps = Transloadit::Rails::Engine.configuration['templates'][template]['steps']
    bucket_source = steps['store'] || steps['store_original']
    bucket = bucket_source['bucket']

    transloadit_data['uploads'].each_with_index.map do |upload_data, index|
      original = transloadit_data['results'][':original'][index]
      # TODO: fetch track name
      s3_paths = { bucket => [{ key: get_file_path(original['ssl_url']) }] }
      upload = Audio.new transloadit_data: transloadit_data.to_hash,
                         s3_paths:         s3_paths,
                         uploadable:       uploadable,
                         user_id:          user.id,
                         type:             'Audio',
                         duration:         upload_data['meta']['duration'],
                         mime_type:        upload_data['mime'],
                         filename:         upload_data['name'],
                         filesize:         upload_data['size'],
                         basename:         upload_data['basename'],
                         url:              original['ssl_url']

      upload.attributes = attributes
      save_or_die! upload
      EventsManager.file_uploaded(user: user, file: upload)
      upload
    end
  end

  def self.remove_post_uploads(ids: [])
    Upload.where(id: ids).find_each do |upload|
      upload.delete_s3_files!
    end
  end

  # @param upload [Upload]
  # @param post [Post]
  def remove_upload(upload: , post: upload.uploadable)
    upload.delete
    EventsManager.upload_removed(user: user, upload: upload)
    PostManager.new(user: user, post: post).turn_to_status_post unless post.try(:status?)
  end

  private

  def search_related_result(collection = [], original_id)
    collection.find { |item| item['original_id'] == original_id }
  end

  def get_file_path(url = '')
    URI(url).path.sub('/', '')
  end
end
