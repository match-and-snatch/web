# @param _params [Hash]
# @return [User]
def create_user(_params = {})
  params = _params.clone
  params.reverse_merge! email:                 'serge@gmail.com',
                        password:              'password',
                        password_confirmation: 'password',
                        first_name:            'sergei',
                        last_name:             'zinin',
                        is_profile_owner:      false

  AuthenticationManager.new(is_profile_owner:      params[:is_profile_owner],
                            email:                 params[:email],
                            password:              params[:password],
                            password_confirmation: params[:password_confirmation],
                            first_name:            params[:first_name],
                            last_name:             params[:last_name]).register
end

# @param _params [Hash]
# @return [User]
def create_admin(_params = {})
  create_user(_params).tap do |user|
    UserManager.new(user).make_admin
  end
end

def transloadit_video_data_params
  {"transloadit" => "{\"ok\":\"ASSEMBLY_COMPLETED\",\"message\":\"The assembly was successfully completed.\",\"assembly_id\":\"c3d12270ca0f11e3978149afb373c5be\",\"parent_id\":null,\"assembly_url\":\"http://api2.jaying.transloadit.com/assemblies/c3d12270ca0f11e3978149afb373c5be\",\"bytes_received\":819539,\"bytes_expected\":819539,\"client_agent\":\"Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36\",\"client_ip\":\"80.64.83.135\",\"client_referer\":\"http://localhost:3001/serg\",\"start_date\":\"2014/04/22 11:18:02 GMT\",\"is_infinite\":false,\"has_dupe_jobs\":false,\"upload_duration\":2.595,\"execution_start\":\"2014/04/22 11:18:04 GMT\",\"execution_duration\":7.771,\"notify_start\":null,\"notify_url\":null,\"notify_status\":null,\"last_job_completed\":\"2014/04/22 11:18:12 GMT\",\"notify_duration\":null,\"fields\":{\"slug\":\"serg\"},\"running_jobs\":[],\"bytes_usage\":2063557,\"executing_jobs\":[],\"started_jobs\":[],\"files_to_store_on_s3\":0,\"queued_files_to_store_on_s3\":0,\"parent_assembly_status\":null,\"params\":\"{\\\"steps\\\":{\\\"files\\\":{\\\"robot\\\":\\\"/file/filter\\\",\\\"accepts\\\":[[\\\"${file.mime}\\\",\\\"regex\\\",\\\"video\\\"]],\\\"error_on_decline\\\":true},\\\"thumbs\\\":{\\\"use\\\":\\\":original\\\",\\\"robot\\\":\\\"/video/thumbs\\\",\\\"count\\\":1},\\\"s3_thumb\\\":{\\\"robot\\\":\\\"/s3/store\\\",\\\"key\\\":\\\"****\\\",\\\"secret\\\":\\\"****\\\",\\\"use\\\":\\\"thumbs\\\",\\\"bucket\\\":\\\"buddy-assets\\\",\\\"path\\\":\\\"uploads/thumbs/${fields.slug}/${assembly.id}____${file.url_name}\\\"},\\\"encode\\\":{\\\"robot\\\":\\\"/video/encode\\\",\\\"use\\\":\\\":original\\\",\\\"ffmpeg_stack\\\":\\\"v2.0.0\\\",\\\"preset\\\":\\\"ipad\\\",\\\"width\\\":null,\\\"height\\\":null,\\\"ffmpeg\\\":{\\\"b\\\":\\\"700k\\\",\\\"vf\\\":\\\"scale='min(iw,1280)':-1\\\"}},\\\"store\\\":{\\\"robot\\\":\\\"/s3/store\\\",\\\"key\\\":\\\"****\\\",\\\"secret\\\":\\\"****\\\",\\\"use\\\":[\\\"encode\\\",\\\":original\\\"],\\\"url_prefix\\\":\\\"s1y5uslj4plb.cloudfront.net/\\\",\\\"bucket\\\":\\\"buddy-video-assets\\\",\\\"path\\\":\\\"${assembly.id}__${file.id}____${file.url_name}\\\"}}}\",\"uploads\":[{\"id\":\"c58b0770ca0f11e3816b1d6c4b95fef4\",\"name\":\"test_video1.mp4\",\"basename\":\"test_video1\",\"ext\":\"mp4\",\"size\":818086,\"mime\":\"video/mp4\",\"type\":\"video\",\"field\":\"post_videos\",\"md5hash\":\"da9725443e8ff4ab10c02cca5a3766bf\",\"original_id\":\"c58b0770ca0f11e3816b1d6c4b95fef4\",\"original_basename\":\"test_video1\",\"original_md5hash\":\"da9725443e8ff4ab10c02cca5a3766bf\",\"url\":\"http://tmp.jaying.transloadit.com/upload/bbe04fba1498ebe89f309906e69a01aa.mp4\",\"meta\":{\"duration\":10.29,\"width\":480,\"height\":360,\"framerate\":30,\"video_bitrate\":214160,\"overall_bitrate\":636024,\"video_codec\":\"ffh264\",\"audio_bitrate\":90552,\"audio_samplerate\":44100,\"audio_channels\":2,\"audio_codec\":\"ffaac\",\"seekable\":true,\"date_recorded\":null,\"date_file_created\":\"2009/03/02 14:54:28\",\"date_file_modified\":\"2014/04/22 11:18:03 GMT\",\"device_vendor\":null,\"device_name\":null,\"device_software\":null,\"latitude\":null,\"longitude\":null,\"rotation\":0,\"album\":null,\"comment\":null,\"year\":null}}],\"last_seq\":5,\"results\":{\"files\":[{\"id\":\"c58b0770ca0f11e3816b1d6c4b95fef4\",\"name\":\"test_video1.mp4\",\"basename\":\"test_video1\",\"ext\":\"mp4\",\"size\":818086,\"mime\":\"video/mp4\",\"type\":\"video\",\"field\":\"post_videos\",\"md5hash\":\"da9725443e8ff4ab10c02cca5a3766bf\",\"original_id\":\"c58b0770ca0f11e3816b1d6c4b95fef4\",\"original_basename\":\"test_video1\",\"original_md5hash\":\"da9725443e8ff4ab10c02cca5a3766bf\",\"url\":\"http://tmp.transloadit.com.s3.amazonaws.com/c58b0770ca0f11e3816b1d6c4b95fef4.mp4\",\"meta\":{\"duration\":10.29,\"width\":480,\"height\":360,\"framerate\":30,\"video_bitrate\":214160,\"overall_bitrate\":636024,\"video_codec\":\"ffh264\",\"audio_bitrate\":90552,\"audio_samplerate\":44100,\"audio_channels\":2,\"audio_codec\":\"ffaac\",\"seekable\":true,\"date_recorded\":null,\"date_file_created\":\"2009/03/02 14:54:28\",\"date_file_modified\":\"2014/04/22 11:18:03 GMT\",\"device_vendor\":null,\"device_name\":null,\"device_software\":null,\"latitude\":null,\"longitude\":null,\"rotation\":0,\"album\":null,\"comment\":null,\"year\":null}}],\":original\":[{\"id\":\"c58b0770ca0f11e3816b1d6c4b95fef4\",\"name\":\"test_video1.mp4\",\"basename\":\"test_video1\",\"ext\":\"mp4\",\"size\":818086,\"mime\":\"video/mp4\",\"type\":\"video\",\"field\":\"post_videos\",\"md5hash\":\"da9725443e8ff4ab10c02cca5a3766bf\",\"original_id\":\"c58b0770ca0f11e3816b1d6c4b95fef4\",\"original_basename\":\"test_video1\",\"original_md5hash\":\"da9725443e8ff4ab10c02cca5a3766bf\",\"url\":\"s1y5uslj4plb.cloudfront.net/c3d12270ca0f11e3978149afb373c5be__c58b0770ca0f11e3816b1d6c4b95fef4____test_video1.mp4\",\"meta\":{\"duration\":10.29,\"width\":480,\"height\":360,\"framerate\":30,\"video_bitrate\":214160,\"overall_bitrate\":636024,\"video_codec\":\"ffh264\",\"audio_bitrate\":90552,\"audio_samplerate\":44100,\"audio_channels\":2,\"audio_codec\":\"ffaac\",\"seekable\":true,\"date_recorded\":null,\"date_file_created\":\"2009/03/02 14:54:28\",\"date_file_modified\":\"2014/04/22 11:18:03 GMT\",\"device_vendor\":null,\"device_name\":null,\"device_software\":null,\"latitude\":null,\"longitude\":null,\"rotation\":0,\"album\":null,\"comment\":null,\"year\":null},\"ssl_url\":\"https://s1y5uslj4plb.cloudfront.net/c3d12270ca0f11e3978149afb373c5be__c58b0770ca0f11e3816b1d6c4b95fef4____test_video1.mp4\"}],\"thumbs\":[{\"id\":\"c6c953d0ca0f11e3b1d3ddbc44dc8502\",\"name\":\"test_video1.jpg\",\"basename\":\"test_video1\",\"ext\":\"jpg\",\"size\":12633,\"mime\":\"image/jpeg\",\"type\":\"image\",\"field\":\"post_videos\",\"md5hash\":\"2c7eabde1555c0a08751e5c88497cda0\",\"original_id\":\"c58b0770ca0f11e3816b1d6c4b95fef4\",\"original_basename\":\"test_video1\",\"original_md5hash\":\"da9725443e8ff4ab10c02cca5a3766bf\",\"url\":\"http://buddy-assets.s3.amazonaws.com/uploads/thumbs/serg/c3d12270ca0f11e3978149afb373c5be____test_video1.jpg\",\"meta\":{\"duration\":10.29,\"width\":480,\"height\":360,\"framerate\":30,\"video_bitrate\":214160,\"overall_bitrate\":636024,\"video_codec\":\"ffh264\",\"audio_bitrate\":90552,\"audio_samplerate\":44100,\"audio_channels\":2,\"audio_codec\":\"ffaac\",\"seekable\":true,\"date_recorded\":null,\"date_file_created\":null,\"date_file_modified\":\"2014/04/22 11:18:06 GMT\",\"device_vendor\":null,\"device_name\":null,\"device_software\":null,\"latitude\":null,\"longitude\":null,\"rotation\":0,\"album\":null,\"comment\":null,\"year\":null,\"thumb_index\":0,\"thumb_offset\":5.145,\"title\":null,\"description\":null,\"location\":null,\"aspect_ratio\":1.3333333333333333,\"city\":null,\"state\":null,\"country\":null,\"country_code\":null,\"keywords\":null,\"aperture\":null,\"exposure_compensation\":null,\"exposure_mode\":null,\"exposure_time\":null,\"flash\":null,\"focal_length\":null,\"f_number\":null,\"iso\":null,\"light_value\":null,\"metering_mode\":null,\"shutter_speed\":null,\"white_balance\":null,\"orientation\":null,\"has_clipping_path\":false,\"creator\":null,\"author\":null,\"copyright\":null,\"copyright_notice\":null,\"frame_count\":1},\"ssl_url\":\"https://buddy-assets.s3.amazonaws.com/uploads/thumbs/serg/c3d12270ca0f11e3978149afb373c5be____test_video1.jpg\"}],\"encode\":[{\"id\":\"c6d1df50ca0f11e3aa5205b417138140\",\"name\":\"test_video1.mp4\",\"basename\":\"test_video1\",\"ext\":\"mp4\",\"size\":1080590,\"mime\":\"video/mp4\",\"type\":\"video\",\"field\":\"post_videos\",\"md5hash\":\"be7993024a884bd584f7b3ce71723a0c\",\"original_id\":\"c58b0770ca0f11e3816b1d6c4b95fef4\",\"original_basename\":\"test_video1\",\"original_md5hash\":\"da9725443e8ff4ab10c02cca5a3766bf\",\"url\":\"s1y5uslj4plb.cloudfront.net/c3d12270ca0f11e3978149afb373c5be__c6d1df50ca0f11e3aa5205b417138140____test_video1.mp4\",\"meta\":{\"duration\":10.4,\"width\":480,\"height\":360,\"framerate\":25,\"video_bitrate\":696864,\"overall_bitrate\":831223,\"video_codec\":\"ffh264\",\"audio_bitrate\":128040,\"audio_samplerate\":48000,\"audio_channels\":2,\"audio_codec\":\"ffaac\",\"seekable\":true,\"date_recorded\":null,\"date_file_created\":\"1904/01/01 00:00:00\",\"date_file_modified\":\"2014/04/22 11:18:08 GMT\",\"device_vendor\":\"Apple\",\"device_name\":null,\"device_software\":null,\"latitude\":null,\"longitude\":null,\"rotation\":0,\"album\":null,\"comment\":null,\"year\":null},\"ssl_url\":\"https://s1y5uslj4plb.cloudfront.net/c3d12270ca0f11e3978149afb373c5be__c6d1df50ca0f11e3aa5205b417138140____test_video1.mp4\"}]}}", "params"=>"{\"steps\":{\"files\":{\"robot\":\"/file/filter\",\"accepts\":[[\"${file.mime}\",\"regex\",\"video\"]],\"error_on_decline\":true},\"thumbs\":{\"use\":\":original\",\"robot\":\"/video/thumbs\",\"count\":1},\"s3_thumb\":{\"robot\":\"/s3/store\",\"key\":\"AKIAJ5KUIYFXQB5KUD5A\",\"secret\":\"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\",\"use\":\"thumbs\",\"bucket\":\"buddy-assets\",\"path\":\"uploads/thumbs/${fields.slug}/${assembly.id}____${file.url_name}\"},\"encode\":{\"robot\":\"/video/encode\",\"use\":\":original\",\"ffmpeg_stack\":\"v2.0.0\",\"preset\":\"ipad\",\"width\":null,\"height\":null,\"ffmpeg\":{\"b\":\"700k\",\"vf\":\"scale='min(iw,1280)':-1\"}},\"store\":{\"robot\":\"/s3/store\",\"key\":\"AKIAJ5KUIYFXQB5KUD5A\",\"secret\":\"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\",\"use\":[\"encode\",\":original\"],\"url_prefix\":\"s1y5uslj4plb.cloudfront.net/\",\"bucket\":\"buddy-video-assets\",\"path\":\"${assembly.id}__${file.id}____${file.url_name}\"}},\"auth\":{\"key\":\"6742a710a9ab11e3a661690b776b09a8\",\"expires\":\"2014/04/22 11:47:52+00:00\"}}", "signature"=>"2a1758fa13c2968fefbed36d5b008b9fd55f1732", "post_videos"=>"", "slug"=>"serg", "authenticity_token"=>"quOFW+WseZBbTN3eZLHGNbyABHpqL38V8CgTOUIIXrQ="}
end

def transloadit_audio_data_params
  {"transloadit"=>"{\"ok\":\"ASSEMBLY_COMPLETED\",\"message\":\"The assembly was successfully completed.\",\"assembly_id\":\"db12aa10cba611e396c70b4999b124a3\",\"parent_id\":null,\"assembly_url\":\"http://api2.atika.transloadit.com/assemblies/db12aa10cba611e396c70b4999b124a3\",\"bytes_received\":61493,\"bytes_expected\":61493,\"client_agent\":\"Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36\",\"client_ip\":\"80.64.83.135\",\"client_referer\":\"http://localhost:3001/serg\",\"start_date\":\"2014/04/24 11:52:06 GMT\",\"is_infinite\":false,\"has_dupe_jobs\":false,\"upload_duration\":1.188,\"execution_start\":\"2014/04/24 11:52:07 GMT\",\"execution_duration\":2.77,\"notify_start\":null,\"notify_url\":null,\"notify_status\":null,\"last_job_completed\":\"2014/04/24 11:52:10 GMT\",\"notify_duration\":null,\"fields\":{\"slug\":\"serg\"},\"running_jobs\":[],\"bytes_usage\":6042,\"executing_jobs\":[],\"started_jobs\":[],\"files_to_store_on_s3\":0,\"queued_files_to_store_on_s3\":0,\"parent_assembly_status\":null,\"params\":\"{\\\"steps\\\":{\\\"files\\\":{\\\"robot\\\":\\\"/file/filter\\\",\\\"accepts\\\":[[\\\"${file.mime}\\\",\\\"regex\\\",\\\"audio\\\"]],\\\"error_on_decline\\\":true},\\\"store\\\":{\\\"robot\\\":\\\"/s3/store\\\",\\\"key\\\":\\\"****\\\",\\\"secret\\\":\\\"****\\\",\\\"use\\\":\\\":original\\\",\\\"bucket\\\":\\\"buddy-video-assets\\\",\\\"path\\\":\\\"${assembly.id}____${file.url_name}\\\",\\\"url_prefix\\\":\\\"s1y5uslj4plb.cloudfront.net/\\\",\\\"headers\\\":{\\\"Content-Type\\\":\\\"${file.mime}\\\",\\\"Content-Disposition\\\":\\\"attachment; filename=${file.url_name}\\\"}}}}\",\"uploads\":[{\"id\":\"dc3c0ee0cba611e38f5eb9fca4b8df1c\",\"name\":\"Developers_converted.mp3\",\"basename\":\"Developers_converted\",\"ext\":\"mp3\",\"size\":60413,\"mime\":\"audio/mpeg\",\"type\":\"audio\",\"field\":\"post_audios\",\"md5hash\":\"0179aa40f9b2982817d718bf9705fdde\",\"original_id\":\"dc3c0ee0cba611e38f5eb9fca4b8df1c\",\"original_basename\":\"Developers_converted\",\"original_md5hash\":\"0179aa40f9b2982817d718bf9705fdde\",\"url\":\"http://tmp.atika.transloadit.com/upload/da28fcf431cecf2285e1d37c7f043ba9.mp3\",\"meta\":{\"duration\":8.624,\"audio_bitrate\":56000,\"overall_bitrate\":null,\"audio_samplerate\":44100,\"audio_channels\":2,\"audio_codec\":\"mp3\",\"encoder\":null,\"beats_per_minute\":null,\"album\":null,\"year\":null,\"genre\":null,\"artist\":null,\"comment\":null,\"performer\":null,\"lyrics\":null,\"title\":null,\"band\":null,\"disc\":null,\"track\":null}}],\"last_seq\":3,\"results\":{\"files\":[{\"id\":\"dc3c0ee0cba611e38f5eb9fca4b8df1c\",\"name\":\"Developers_converted.mp3\",\"basename\":\"Developers_converted\",\"ext\":\"mp3\",\"size\":60413,\"mime\":\"audio/mpeg\",\"type\":\"audio\",\"field\":\"post_audios\",\"md5hash\":\"0179aa40f9b2982817d718bf9705fdde\",\"original_id\":\"dc3c0ee0cba611e38f5eb9fca4b8df1c\",\"original_basename\":\"Developers_converted\",\"original_md5hash\":\"0179aa40f9b2982817d718bf9705fdde\",\"url\":\"http://tmp.transloadit.com.s3.amazonaws.com/dc3c0ee0cba611e38f5eb9fca4b8df1c.mp3\",\"meta\":{\"duration\":8.624,\"audio_bitrate\":56000,\"overall_bitrate\":null,\"audio_samplerate\":44100,\"audio_channels\":2,\"audio_codec\":\"mp3\",\"encoder\":null,\"beats_per_minute\":null,\"album\":null,\"year\":null,\"genre\":null,\"artist\":null,\"comment\":null,\"performer\":null,\"lyrics\":null,\"title\":null,\"band\":null,\"disc\":null,\"track\":null}}],\":original\":[{\"id\":\"dc3c0ee0cba611e38f5eb9fca4b8df1c\",\"name\":\"Developers_converted.mp3\",\"basename\":\"Developers_converted\",\"ext\":\"mp3\",\"size\":60413,\"mime\":\"audio/mpeg\",\"type\":\"audio\",\"field\":\"post_audios\",\"md5hash\":\"0179aa40f9b2982817d718bf9705fdde\",\"original_id\":\"dc3c0ee0cba611e38f5eb9fca4b8df1c\",\"original_basename\":\"Developers_converted\",\"original_md5hash\":\"0179aa40f9b2982817d718bf9705fdde\",\"url\":\"s1y5uslj4plb.cloudfront.net/db12aa10cba611e396c70b4999b124a3____Developers_converted.mp3\",\"meta\":{\"duration\":8.624,\"audio_bitrate\":56000,\"overall_bitrate\":null,\"audio_samplerate\":44100,\"audio_channels\":2,\"audio_codec\":\"mp3\",\"encoder\":null,\"beats_per_minute\":null,\"album\":null,\"year\":null,\"genre\":null,\"artist\":null,\"comment\":null,\"performer\":null,\"lyrics\":null,\"title\":null,\"band\":null,\"disc\":null,\"track\":null},\"ssl_url\":\"https://s1y5uslj4plb.cloudfront.net/db12aa10cba611e396c70b4999b124a3____Developers_converted.mp3\"}]}}", "params"=>"{\"steps\":{\"files\":{\"robot\":\"/file/filter\",\"accepts\":[[\"${file.mime}\",\"regex\",\"audio\"]],\"error_on_decline\":true},\"store\":{\"robot\":\"/s3/store\",\"key\":\"AKIAJ5KUIYFXQB5KUD5A\",\"secret\":\"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\",\"use\":\":original\",\"bucket\":\"buddy-video-assets\",\"path\":\"${assembly.id}____${file.url_name}\",\"url_prefix\":\"s1y5uslj4plb.cloudfront.net/\",\"headers\":{\"Content-Type\":\"${file.mime}\",\"Content-Disposition\":\"attachment; filename=${file.url_name}\"}}},\"auth\":{\"key\":\"6742a710a9ab11e3a661690b776b09a8\",\"expires\":\"2014/04/24 12:21:57+00:00\"}}", "signature"=>"6144015e473ff09fec1281c6ee31c50533b84dbb", "post_audios"=>"", "slug"=>"serg", "authenticity_token"=>"xy0DITwNoKHZUXzXtPSTGMUi6uGnYu1mrqmBCahZsG4="}
end

def transloadit_photo_data_params
  {"transloadit"=>"{\"ok\":\"ASSEMBLY_COMPLETED\",\"message\":\"The assembly was successfully completed.\",\"assembly_id\":\"174dff50ca3211e3aadbe7db767689d9\",\"parent_id\":null,\"assembly_url\":\"http://api2.jaying.transloadit.com/assemblies/174dff50ca3211e3aadbe7db767689d9\",\"bytes_received\":7955,\"bytes_expected\":7955,\"client_agent\":\"Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36\",\"client_ip\":\"80.64.83.135\",\"client_referer\":\"http://localhost:3001/serg\",\"start_date\":\"2014/04/22 15:23:45 GMT\",\"is_infinite\":false,\"has_dupe_jobs\":false,\"upload_duration\":0.829,\"execution_start\":\"2014/04/22 15:23:46 GMT\",\"execution_duration\":3.392,\"notify_start\":null,\"notify_url\":null,\"notify_status\":null,\"last_job_completed\":\"2014/04/22 15:23:49 GMT\",\"notify_duration\":null,\"fields\":{\"slug\":\"serg\"},\"running_jobs\":[],\"bytes_usage\":10021,\"executing_jobs\":[],\"started_jobs\":[],\"files_to_store_on_s3\":0,\"queued_files_to_store_on_s3\":0,\"parent_assembly_status\":null,\"params\":\"{\\\"steps\\\":{\\\"files\\\":{\\\"robot\\\":\\\"/file/filter\\\",\\\"accepts\\\":[[\\\"${file.mime}\\\",\\\"regex\\\",\\\"image\\\"]],\\\"error_on_decline\\\":true},\\\"preview\\\":{\\\"robot\\\":\\\"/image/resize\\\",\\\"use\\\":\\\":original\\\",\\\"width\\\":100,\\\"height\\\":100,\\\"resize_strategy\\\":\\\"fillcrop\\\"},\\\"store\\\":{\\\"robot\\\":\\\"/s3/store\\\",\\\"key\\\":\\\"****\\\",\\\"secret\\\":\\\"****\\\",\\\"use\\\":[\\\":original\\\",\\\"preview\\\"],\\\"bucket\\\":\\\"buddy-assets\\\",\\\"path\\\":\\\"uploads/post_photos/${fields.slug}/${assembly.id}____${file.meta.width}x${file.meta.height}____${file.url_name}\\\"}}}\",\"uploads\":[{\"id\":\"188dd250ca3211e393afb33ba35c9cc7\",\"name\":\"extrim.jpg\",\"basename\":\"extrim\",\"ext\":\"jpg\",\"size\":6845,\"mime\":\"image/jpeg\",\"type\":\"image\",\"field\":\"post_photos\",\"md5hash\":\"98a9d280301f9fd43e1109452193ad10\",\"original_id\":\"188dd250ca3211e393afb33ba35c9cc7\",\"original_basename\":\"extrim\",\"original_md5hash\":\"98a9d280301f9fd43e1109452193ad10\",\"url\":\"http://tmp.jaying.transloadit.com/upload/cf948d945a315a47c47b9ee0406f6383.jpg\",\"meta\":{\"width\":259,\"height\":194,\"date_recorded\":null,\"date_file_created\":null,\"date_file_modified\":\"2014/04/22 15:23:45 GMT\",\"title\":null,\"description\":null,\"location\":null,\"aspect_ratio\":1.3350515463917525,\"city\":null,\"state\":null,\"country\":null,\"country_code\":null,\"keywords\":null,\"aperture\":null,\"exposure_compensation\":null,\"exposure_mode\":null,\"exposure_time\":null,\"flash\":null,\"focal_length\":null,\"f_number\":null,\"iso\":null,\"light_value\":null,\"metering_mode\":null,\"shutter_speed\":null,\"white_balance\":null,\"device_name\":null,\"device_vendor\":null,\"device_software\":null,\"latitude\":null,\"longitude\":null,\"orientation\":null,\"has_clipping_path\":false,\"creator\":null,\"author\":null,\"copyright\":null,\"copyright_notice\":null,\"frame_count\":1}}],\"last_seq\":4,\"results\":{\"files\":[{\"id\":\"188dd250ca3211e393afb33ba35c9cc7\",\"name\":\"extrim.jpg\",\"basename\":\"extrim\",\"ext\":\"jpg\",\"size\":6845,\"mime\":\"image/jpeg\",\"type\":\"image\",\"field\":\"post_photos\",\"md5hash\":\"98a9d280301f9fd43e1109452193ad10\",\"original_id\":\"188dd250ca3211e393afb33ba35c9cc7\",\"original_basename\":\"extrim\",\"original_md5hash\":\"98a9d280301f9fd43e1109452193ad10\",\"url\":\"http://tmp.transloadit.com.s3.amazonaws.com/188dd250ca3211e393afb33ba35c9cc7.jpg\",\"meta\":{\"width\":259,\"height\":194,\"date_recorded\":null,\"date_file_created\":null,\"date_file_modified\":\"2014/04/22 15:23:45 GMT\",\"title\":null,\"description\":null,\"location\":null,\"aspect_ratio\":1.3350515463917525,\"city\":null,\"state\":null,\"country\":null,\"country_code\":null,\"keywords\":null,\"aperture\":null,\"exposure_compensation\":null,\"exposure_mode\":null,\"exposure_time\":null,\"flash\":null,\"focal_length\":null,\"f_number\":null,\"iso\":null,\"light_value\":null,\"metering_mode\":null,\"shutter_speed\":null,\"white_balance\":null,\"device_name\":null,\"device_vendor\":null,\"device_software\":null,\"latitude\":null,\"longitude\":null,\"orientation\":null,\"has_clipping_path\":false,\"creator\":null,\"author\":null,\"copyright\":null,\"copyright_notice\":null,\"frame_count\":1}}],\":original\":[{\"id\":\"188dd250ca3211e393afb33ba35c9cc7\",\"name\":\"extrim.jpg\",\"basename\":\"extrim\",\"ext\":\"jpg\",\"size\":6845,\"mime\":\"image/jpeg\",\"type\":\"image\",\"field\":\"post_photos\",\"md5hash\":\"98a9d280301f9fd43e1109452193ad10\",\"original_id\":\"188dd250ca3211e393afb33ba35c9cc7\",\"original_basename\":\"extrim\",\"original_md5hash\":\"98a9d280301f9fd43e1109452193ad10\",\"url\":\"http://buddy-assets.s3.amazonaws.com/uploads/post_photos/serg/174dff50ca3211e3aadbe7db767689d9____259x194____extrim.jpg\",\"meta\":{\"width\":259,\"height\":194,\"date_recorded\":null,\"date_file_created\":null,\"date_file_modified\":\"2014/04/22 15:23:45 GMT\",\"title\":null,\"description\":null,\"location\":null,\"aspect_ratio\":1.3350515463917525,\"city\":null,\"state\":null,\"country\":null,\"country_code\":null,\"keywords\":null,\"aperture\":null,\"exposure_compensation\":null,\"exposure_mode\":null,\"exposure_time\":null,\"flash\":null,\"focal_length\":null,\"f_number\":null,\"iso\":null,\"light_value\":null,\"metering_mode\":null,\"shutter_speed\":null,\"white_balance\":null,\"device_name\":null,\"device_vendor\":null,\"device_software\":null,\"latitude\":null,\"longitude\":null,\"orientation\":null,\"has_clipping_path\":false,\"creator\":null,\"author\":null,\"copyright\":null,\"copyright_notice\":null,\"frame_count\":1},\"ssl_url\":\"https://buddy-assets.s3.amazonaws.com/uploads/post_photos/serg/174dff50ca3211e3aadbe7db767689d9____259x194____extrim.jpg\"}],\"preview\":[{\"id\":\"1971c9b0ca3211e39a3621fe968c33bd\",\"name\":\"extrim.jpg\",\"basename\":\"extrim\",\"ext\":\"jpg\",\"size\":2491,\"mime\":\"image/jpeg\",\"type\":\"image\",\"field\":\"post_photos\",\"md5hash\":\"f7c5f38bab53339a0d5c59a6a7f6411f\",\"original_id\":\"188dd250ca3211e393afb33ba35c9cc7\",\"original_basename\":\"extrim\",\"original_md5hash\":\"98a9d280301f9fd43e1109452193ad10\",\"url\":\"http://buddy-assets.s3.amazonaws.com/uploads/post_photos/serg/174dff50ca3211e3aadbe7db767689d9____100x100____extrim.jpg\",\"meta\":{\"width\":100,\"height\":100,\"date_recorded\":null,\"date_file_created\":null,\"date_file_modified\":\"2014/04/22 15:23:47 GMT\",\"title\":null,\"description\":null,\"location\":null,\"aspect_ratio\":1,\"city\":null,\"state\":null,\"country\":null,\"country_code\":null,\"keywords\":null,\"aperture\":null,\"exposure_compensation\":null,\"exposure_mode\":null,\"exposure_time\":null,\"flash\":null,\"focal_length\":null,\"f_number\":null,\"iso\":null,\"light_value\":null,\"metering_mode\":null,\"shutter_speed\":null,\"white_balance\":null,\"device_name\":null,\"device_vendor\":null,\"device_software\":null,\"latitude\":null,\"longitude\":null,\"orientation\":null,\"has_clipping_path\":false,\"creator\":null,\"author\":null,\"copyright\":null,\"copyright_notice\":null,\"frame_count\":1},\"ssl_url\":\"https://buddy-assets.s3.amazonaws.com/uploads/post_photos/serg/174dff50ca3211e3aadbe7db767689d9____100x100____extrim.jpg\"}]}}", "params"=>"{\"steps\":{\"files\":{\"robot\":\"/file/filter\",\"accepts\":[[\"${file.mime}\",\"regex\",\"image\"]],\"error_on_decline\":true},\"preview\":{\"robot\":\"/image/resize\",\"use\":\":original\",\"width\":100,\"height\":100,\"resize_strategy\":\"fillcrop\"},\"store\":{\"robot\":\"/s3/store\",\"key\":\"AKIAJ5KUIYFXQB5KUD5A\",\"secret\":\"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\",\"use\":[\":original\",\"preview\"],\"bucket\":\"buddy-assets\",\"path\":\"uploads/post_photos/${fields.slug}/${assembly.id}____${file.meta.width}x${file.meta.height}____${file.url_name}\"}},\"auth\":{\"key\":\"6742a710a9ab11e3a661690b776b09a8\",\"expires\":\"2014/04/22 15:53:41+00:00\"}}", "signature"=>"89fe628136c22da4aa39aa0037674608279183e8", "post_photos"=>"", "slug"=>"serg", "authenticity_token"=>"quOFW+WseZBbTN3eZLHGNbyABHpqL38V8CgTOUIIXrQ="}
end

def transloadit_document_data_params
  {"transloadit"=>"{\"ok\":\"ASSEMBLY_COMPLETED\",\"message\":\"The assembly was successfully completed.\",\"assembly_id\":\"ac03e030ca2611e3ad989d7c0e8dc643\",\"parent_id\":null,\"assembly_url\":\"http://api2.ifrah.transloadit.com/assemblies/ac03e030ca2611e3ad989d7c0e8dc643\",\"bytes_received\":73317,\"bytes_expected\":73317,\"client_agent\":\"Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36\",\"client_ip\":\"80.64.83.135\",\"client_referer\":\"http://localhost:3001/serg\",\"start_date\":\"2014/04/22 14:02:00 GMT\",\"is_infinite\":false,\"has_dupe_jobs\":false,\"upload_duration\":1.443,\"execution_start\":\"2014/04/22 14:02:02 GMT\",\"execution_duration\":2.92,\"notify_start\":null,\"notify_url\":null,\"notify_status\":null,\"last_job_completed\":\"2014/04/22 14:02:05 GMT\",\"notify_duration\":null,\"fields\":{\"slug\":\"serg\"},\"running_jobs\":[],\"bytes_usage\":7232,\"executing_jobs\":[],\"started_jobs\":[],\"files_to_store_on_s3\":0,\"queued_files_to_store_on_s3\":0,\"parent_assembly_status\":null,\"params\":\"{\\\"steps\\\":{\\\"files\\\":{\\\"robot\\\":\\\"/file/filter\\\",\\\"accepts\\\":[[\\\"${file.name}\\\",\\\"regex\\\",\\\".+[^\\\\\\\\.(exe|bin|dll|js|sh|bash|rb|py)]$\\\"]],\\\"error_on_decline\\\":true},\\\"store\\\":{\\\"robot\\\":\\\"/s3/store\\\",\\\"key\\\":\\\"****\\\",\\\"secret\\\":\\\"****\\\",\\\"use\\\":\\\":original\\\",\\\"bucket\\\":\\\"buddy-private-assets\\\",\\\"path\\\":\\\"uploads/post_documents/${fields.slug}/${assembly.id}/${file.url_name}\\\"}}}\",\"uploads\":[{\"id\":\"ad863a70ca2611e395b037db04dd3c0c\",\"name\":\"Codility.pdf\",\"basename\":\"Codility\",\"ext\":\"pdf\",\"size\":72317,\"mime\":\"application/pdf\",\"type\":\"pdf\",\"field\":\"post_documents\",\"md5hash\":\"ae13512d0f6ecfc632034d1f5f0e24d7\",\"original_id\":\"ad863a70ca2611e395b037db04dd3c0c\",\"original_basename\":\"Codility\",\"original_md5hash\":\"ae13512d0f6ecfc632034d1f5f0e24d7\",\"url\":\"http://tmp.ifrah.transloadit.com/upload/be4d2ecd43f511b94606bcd383537a31.pdf\",\"meta\":{\"page_count\":2,\"title\":null,\"author\":null,\"producer\":null,\"creator\":null,\"create_date\":null,\"modify_date\":null}}],\"last_seq\":3,\"results\":{\"files\":[{\"id\":\"ad863a70ca2611e395b037db04dd3c0c\",\"name\":\"Codility.pdf\",\"basename\":\"Codility\",\"ext\":\"pdf\",\"size\":72317,\"mime\":\"application/pdf\",\"type\":\"pdf\",\"field\":\"post_documents\",\"md5hash\":\"ae13512d0f6ecfc632034d1f5f0e24d7\",\"original_id\":\"ad863a70ca2611e395b037db04dd3c0c\",\"original_basename\":\"Codility\",\"original_md5hash\":\"ae13512d0f6ecfc632034d1f5f0e24d7\",\"url\":\"http://tmp.transloadit.com.s3.amazonaws.com/ad863a70ca2611e395b037db04dd3c0c.pdf\",\"meta\":{\"page_count\":2,\"title\":null,\"author\":null,\"producer\":null,\"creator\":null,\"create_date\":null,\"modify_date\":null}}],\":original\":[{\"id\":\"ad863a70ca2611e395b037db04dd3c0c\",\"name\":\"Codility.pdf\",\"basename\":\"Codility\",\"ext\":\"pdf\",\"size\":72317,\"mime\":\"application/pdf\",\"type\":\"pdf\",\"field\":\"post_documents\",\"md5hash\":\"ae13512d0f6ecfc632034d1f5f0e24d7\",\"original_id\":\"ad863a70ca2611e395b037db04dd3c0c\",\"original_basename\":\"Codility\",\"original_md5hash\":\"ae13512d0f6ecfc632034d1f5f0e24d7\",\"url\":\"http://buddy-private-assets.s3.amazonaws.com/uploads/post_documents/serg/ac03e030ca2611e3ad989d7c0e8dc643/Codility.pdf\",\"meta\":{\"page_count\":2,\"title\":null,\"author\":null,\"producer\":null,\"creator\":null,\"create_date\":null,\"modify_date\":null},\"ssl_url\":\"https://buddy-private-assets.s3.amazonaws.com/uploads/post_documents/serg/ac03e030ca2611e3ad989d7c0e8dc643/Codility.pdf\"}]}}", "params"=>"{\"steps\":{\"files\":{\"robot\":\"/file/filter\",\"accepts\":[[\"${file.name}\",\"regex\",\".+[^\\\\.(exe|bin|dll|js|sh|bash|rb|py)]$\"]],\"error_on_decline\":true},\"store\":{\"robot\":\"/s3/store\",\"key\":\"AKIAJ5KUIYFXQB5KUD5A\",\"secret\":\"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\",\"use\":\":original\",\"bucket\":\"buddy-private-assets\",\"path\":\"uploads/post_documents/${fields.slug}/${assembly.id}/${file.url_name}\"}},\"auth\":{\"key\":\"6742a710a9ab11e3a661690b776b09a8\",\"expires\":\"2014/04/22 14:31:42+00:00\"}}", "signature"=>"a069a3694804f9106e204b35042ca746a7c1a0ca", "post_documents"=>"", "slug"=>"serg", "authenticity_token"=>"quOFW+WseZBbTN3eZLHGNbyABHpqL38V8CgTOUIIXrQ="}
end

def create_video_upload(user)
  UploadManager.new(user).create_pending_video(JSON.parse(transloadit_video_data_params['transloadit']))
end

def create_audios_upload(user)
  UploadManager.new(user).create_pending_audios(JSON.parse(transloadit_audio_data_params['transloadit']))
end

def create_documents_upload(user, _params = {})
  UploadManager.new(user).create_pending_documents(JSON.parse(transloadit_document_data_params['transloadit']))
end

def create_photo_upload(user)
  UploadManager.new(user).create_pending_photos(JSON.parse(transloadit_photo_data_params['transloadit']))
end