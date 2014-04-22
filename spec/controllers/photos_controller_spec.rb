require 'spec_helper'

transloadit_data = {"transloadit"=>"{\"ok\":\"ASSEMBLY_COMPLETED\",\"message\":\"The assembly was successfully completed.\",\"assembly_id\":\"174dff50ca3211e3aadbe7db767689d9\",\"parent_id\":null,\"assembly_url\":\"http://api2.jaying.transloadit.com/assemblies/174dff50ca3211e3aadbe7db767689d9\",\"bytes_received\":7955,\"bytes_expected\":7955,\"client_agent\":\"Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36\",\"client_ip\":\"80.64.83.135\",\"client_referer\":\"http://localhost:3001/serg\",\"start_date\":\"2014/04/22 15:23:45 GMT\",\"is_infinite\":false,\"has_dupe_jobs\":false,\"upload_duration\":0.829,\"execution_start\":\"2014/04/22 15:23:46 GMT\",\"execution_duration\":3.392,\"notify_start\":null,\"notify_url\":null,\"notify_status\":null,\"last_job_completed\":\"2014/04/22 15:23:49 GMT\",\"notify_duration\":null,\"fields\":{\"slug\":\"serg\"},\"running_jobs\":[],\"bytes_usage\":10021,\"executing_jobs\":[],\"started_jobs\":[],\"files_to_store_on_s3\":0,\"queued_files_to_store_on_s3\":0,\"parent_assembly_status\":null,\"params\":\"{\\\"steps\\\":{\\\"files\\\":{\\\"robot\\\":\\\"/file/filter\\\",\\\"accepts\\\":[[\\\"${file.mime}\\\",\\\"regex\\\",\\\"image\\\"]],\\\"error_on_decline\\\":true},\\\"preview\\\":{\\\"robot\\\":\\\"/image/resize\\\",\\\"use\\\":\\\":original\\\",\\\"width\\\":100,\\\"height\\\":100,\\\"resize_strategy\\\":\\\"fillcrop\\\"},\\\"store\\\":{\\\"robot\\\":\\\"/s3/store\\\",\\\"key\\\":\\\"****\\\",\\\"secret\\\":\\\"****\\\",\\\"use\\\":[\\\":original\\\",\\\"preview\\\"],\\\"bucket\\\":\\\"buddy-assets\\\",\\\"path\\\":\\\"uploads/post_photos/${fields.slug}/${assembly.id}____${file.meta.width}x${file.meta.height}____${file.url_name}\\\"}}}\",\"uploads\":[{\"id\":\"188dd250ca3211e393afb33ba35c9cc7\",\"name\":\"extrim.jpg\",\"basename\":\"extrim\",\"ext\":\"jpg\",\"size\":6845,\"mime\":\"image/jpeg\",\"type\":\"image\",\"field\":\"post_photos\",\"md5hash\":\"98a9d280301f9fd43e1109452193ad10\",\"original_id\":\"188dd250ca3211e393afb33ba35c9cc7\",\"original_basename\":\"extrim\",\"original_md5hash\":\"98a9d280301f9fd43e1109452193ad10\",\"url\":\"http://tmp.jaying.transloadit.com/upload/cf948d945a315a47c47b9ee0406f6383.jpg\",\"meta\":{\"width\":259,\"height\":194,\"date_recorded\":null,\"date_file_created\":null,\"date_file_modified\":\"2014/04/22 15:23:45 GMT\",\"title\":null,\"description\":null,\"location\":null,\"aspect_ratio\":1.3350515463917525,\"city\":null,\"state\":null,\"country\":null,\"country_code\":null,\"keywords\":null,\"aperture\":null,\"exposure_compensation\":null,\"exposure_mode\":null,\"exposure_time\":null,\"flash\":null,\"focal_length\":null,\"f_number\":null,\"iso\":null,\"light_value\":null,\"metering_mode\":null,\"shutter_speed\":null,\"white_balance\":null,\"device_name\":null,\"device_vendor\":null,\"device_software\":null,\"latitude\":null,\"longitude\":null,\"orientation\":null,\"has_clipping_path\":false,\"creator\":null,\"author\":null,\"copyright\":null,\"copyright_notice\":null,\"frame_count\":1}}],\"last_seq\":4,\"results\":{\"files\":[{\"id\":\"188dd250ca3211e393afb33ba35c9cc7\",\"name\":\"extrim.jpg\",\"basename\":\"extrim\",\"ext\":\"jpg\",\"size\":6845,\"mime\":\"image/jpeg\",\"type\":\"image\",\"field\":\"post_photos\",\"md5hash\":\"98a9d280301f9fd43e1109452193ad10\",\"original_id\":\"188dd250ca3211e393afb33ba35c9cc7\",\"original_basename\":\"extrim\",\"original_md5hash\":\"98a9d280301f9fd43e1109452193ad10\",\"url\":\"http://tmp.transloadit.com.s3.amazonaws.com/188dd250ca3211e393afb33ba35c9cc7.jpg\",\"meta\":{\"width\":259,\"height\":194,\"date_recorded\":null,\"date_file_created\":null,\"date_file_modified\":\"2014/04/22 15:23:45 GMT\",\"title\":null,\"description\":null,\"location\":null,\"aspect_ratio\":1.3350515463917525,\"city\":null,\"state\":null,\"country\":null,\"country_code\":null,\"keywords\":null,\"aperture\":null,\"exposure_compensation\":null,\"exposure_mode\":null,\"exposure_time\":null,\"flash\":null,\"focal_length\":null,\"f_number\":null,\"iso\":null,\"light_value\":null,\"metering_mode\":null,\"shutter_speed\":null,\"white_balance\":null,\"device_name\":null,\"device_vendor\":null,\"device_software\":null,\"latitude\":null,\"longitude\":null,\"orientation\":null,\"has_clipping_path\":false,\"creator\":null,\"author\":null,\"copyright\":null,\"copyright_notice\":null,\"frame_count\":1}}],\":original\":[{\"id\":\"188dd250ca3211e393afb33ba35c9cc7\",\"name\":\"extrim.jpg\",\"basename\":\"extrim\",\"ext\":\"jpg\",\"size\":6845,\"mime\":\"image/jpeg\",\"type\":\"image\",\"field\":\"post_photos\",\"md5hash\":\"98a9d280301f9fd43e1109452193ad10\",\"original_id\":\"188dd250ca3211e393afb33ba35c9cc7\",\"original_basename\":\"extrim\",\"original_md5hash\":\"98a9d280301f9fd43e1109452193ad10\",\"url\":\"http://buddy-assets.s3.amazonaws.com/uploads/post_photos/serg/174dff50ca3211e3aadbe7db767689d9____259x194____extrim.jpg\",\"meta\":{\"width\":259,\"height\":194,\"date_recorded\":null,\"date_file_created\":null,\"date_file_modified\":\"2014/04/22 15:23:45 GMT\",\"title\":null,\"description\":null,\"location\":null,\"aspect_ratio\":1.3350515463917525,\"city\":null,\"state\":null,\"country\":null,\"country_code\":null,\"keywords\":null,\"aperture\":null,\"exposure_compensation\":null,\"exposure_mode\":null,\"exposure_time\":null,\"flash\":null,\"focal_length\":null,\"f_number\":null,\"iso\":null,\"light_value\":null,\"metering_mode\":null,\"shutter_speed\":null,\"white_balance\":null,\"device_name\":null,\"device_vendor\":null,\"device_software\":null,\"latitude\":null,\"longitude\":null,\"orientation\":null,\"has_clipping_path\":false,\"creator\":null,\"author\":null,\"copyright\":null,\"copyright_notice\":null,\"frame_count\":1},\"ssl_url\":\"https://buddy-assets.s3.amazonaws.com/uploads/post_photos/serg/174dff50ca3211e3aadbe7db767689d9____259x194____extrim.jpg\"}],\"preview\":[{\"id\":\"1971c9b0ca3211e39a3621fe968c33bd\",\"name\":\"extrim.jpg\",\"basename\":\"extrim\",\"ext\":\"jpg\",\"size\":2491,\"mime\":\"image/jpeg\",\"type\":\"image\",\"field\":\"post_photos\",\"md5hash\":\"f7c5f38bab53339a0d5c59a6a7f6411f\",\"original_id\":\"188dd250ca3211e393afb33ba35c9cc7\",\"original_basename\":\"extrim\",\"original_md5hash\":\"98a9d280301f9fd43e1109452193ad10\",\"url\":\"http://buddy-assets.s3.amazonaws.com/uploads/post_photos/serg/174dff50ca3211e3aadbe7db767689d9____100x100____extrim.jpg\",\"meta\":{\"width\":100,\"height\":100,\"date_recorded\":null,\"date_file_created\":null,\"date_file_modified\":\"2014/04/22 15:23:47 GMT\",\"title\":null,\"description\":null,\"location\":null,\"aspect_ratio\":1,\"city\":null,\"state\":null,\"country\":null,\"country_code\":null,\"keywords\":null,\"aperture\":null,\"exposure_compensation\":null,\"exposure_mode\":null,\"exposure_time\":null,\"flash\":null,\"focal_length\":null,\"f_number\":null,\"iso\":null,\"light_value\":null,\"metering_mode\":null,\"shutter_speed\":null,\"white_balance\":null,\"device_name\":null,\"device_vendor\":null,\"device_software\":null,\"latitude\":null,\"longitude\":null,\"orientation\":null,\"has_clipping_path\":false,\"creator\":null,\"author\":null,\"copyright\":null,\"copyright_notice\":null,\"frame_count\":1},\"ssl_url\":\"https://buddy-assets.s3.amazonaws.com/uploads/post_photos/serg/174dff50ca3211e3aadbe7db767689d9____100x100____extrim.jpg\"}]}}", "params"=>"{\"steps\":{\"files\":{\"robot\":\"/file/filter\",\"accepts\":[[\"${file.mime}\",\"regex\",\"image\"]],\"error_on_decline\":true},\"preview\":{\"robot\":\"/image/resize\",\"use\":\":original\",\"width\":100,\"height\":100,\"resize_strategy\":\"fillcrop\"},\"store\":{\"robot\":\"/s3/store\",\"key\":\"AKIAJ5KUIYFXQB5KUD5A\",\"secret\":\"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\",\"use\":[\":original\",\"preview\"],\"bucket\":\"buddy-assets\",\"path\":\"uploads/post_photos/${fields.slug}/${assembly.id}____${file.meta.width}x${file.meta.height}____${file.url_name}\"}},\"auth\":{\"key\":\"6742a710a9ab11e3a661690b776b09a8\",\"expires\":\"2014/04/22 15:53:41+00:00\"}}", "signature"=>"89fe628136c22da4aa39aa0037674608279183e8", "post_photos"=>"", "slug"=>"serg", "authenticity_token"=>"quOFW+WseZBbTN3eZLHGNbyABHpqL38V8CgTOUIIXrQ="}

describe PhotosController do
  let(:owner) { create_user email: 'owner@gmail.com', is_profile_owner: true }

  describe 'GET #profile_picture' do
    subject { get 'profile_picture', user_id: owner.slug }

    context 'unauthorized access' do
      its(:status) { should == 200 }
    end

    context 'authorized access' do
      before { sign_in owner }
      its(:status) { should == 200 }
    end
  end

  describe 'GET #cover_picture' do
    subject { get 'cover_picture', user_id: owner.slug }

    context 'unauthorized access' do
      its(:status) { should == 200 }
    end

    context 'authorized access' do
      before { sign_in owner }
      its(:status) { should == 200 }
    end
  end

  describe 'POST #create' do
    subject { post 'create', transloadit_data }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      before { sign_in owner }
      its(:status) { should == 200 }
    end
  end

  describe 'DELETE #destroy' do
    let(:photo_upload) { create_photo_upload(owner, transloadit: JSON.parse(transloadit_data['transloadit'])).first  }
    subject { delete 'destroy', id: photo_upload.id }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      before { sign_in owner }
      its(:status) { should == 200 }
    end
  end
end