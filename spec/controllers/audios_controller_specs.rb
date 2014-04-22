require 'spec_helper'

transloadit_data = {"transloadit"=>"{\"ok\":\"ASSEMBLY_COMPLETED\",\"message\":\"The assembly was successfully completed.\",\"assembly_id\":\"c5a3a870ca2311e3839773efa7db3d59\",\"parent_id\":null,\"assembly_url\":\"http://api2.keemaya.transloadit.com/assemblies/c5a3a870ca2311e3839773efa7db3d59\",\"bytes_received\":61389,\"bytes_expected\":61389,\"client_agent\":\"Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36\",\"client_ip\":\"80.64.83.135\",\"client_referer\":\"http://localhost:3001/serg\",\"start_date\":\"2014/04/22 13:41:15 GMT\",\"is_infinite\":false,\"has_dupe_jobs\":false,\"upload_duration\":1.211,\"execution_start\":\"2014/04/22 13:41:16 GMT\",\"execution_duration\":2.919,\"notify_start\":null,\"notify_url\":null,\"notify_status\":null,\"last_job_completed\":\"2014/04/22 13:41:19 GMT\",\"notify_duration\":null,\"fields\":{\"slug\":\"serg\"},\"running_jobs\":[],\"bytes_usage\":6042,\"executing_jobs\":[],\"started_jobs\":[],\"files_to_store_on_s3\":0,\"queued_files_to_store_on_s3\":0,\"parent_assembly_status\":null,\"params\":\"{\\\"steps\\\":{\\\"files\\\":{\\\"robot\\\":\\\"/file/filter\\\",\\\"accepts\\\":[[\\\"${file.mime}\\\",\\\"regex\\\",\\\"audio\\\"]],\\\"error_on_decline\\\":true},\\\"store\\\":{\\\"robot\\\":\\\"/s3/store\\\",\\\"key\\\":\\\"****\\\",\\\"secret\\\":\\\"****\\\",\\\"use\\\":\\\":original\\\",\\\"url_prefix\\\":\\\"s1y5uslj4plb.cloudfront.net/\\\",\\\"bucket\\\":\\\"buddy-video-assets\\\",\\\"path\\\":\\\"${assembly.id}____${file.url_name}\\\"}}}\",\"uploads\":[{\"id\":\"c6ef3b40ca2311e3b45195d9609cd3b5\",\"name\":\"Developers_converted.mp3\",\"basename\":\"Developers_converted\",\"ext\":\"mp3\",\"size\":60413,\"mime\":\"audio/mpeg\",\"type\":\"audio\",\"field\":\"post_audios\",\"md5hash\":\"0179aa40f9b2982817d718bf9705fdde\",\"original_id\":\"c6ef3b40ca2311e3b45195d9609cd3b5\",\"original_basename\":\"Developers_converted\",\"original_md5hash\":\"0179aa40f9b2982817d718bf9705fdde\",\"url\":\"http://tmp.keemaya.transloadit.com/upload/0204784a4ddd3edd6426ed19fb8d902e.mp3\",\"meta\":{\"duration\":8.624,\"audio_bitrate\":56000,\"overall_bitrate\":null,\"audio_samplerate\":44100,\"audio_channels\":2,\"audio_codec\":\"mp3\",\"encoder\":null,\"beats_per_minute\":null,\"album\":null,\"year\":null,\"genre\":null,\"artist\":null,\"comment\":null,\"performer\":null,\"lyrics\":null,\"title\":null,\"band\":null,\"disc\":null,\"track\":null}}],\"last_seq\":3,\"results\":{\"files\":[{\"id\":\"c6ef3b40ca2311e3b45195d9609cd3b5\",\"name\":\"Developers_converted.mp3\",\"basename\":\"Developers_converted\",\"ext\":\"mp3\",\"size\":60413,\"mime\":\"audio/mpeg\",\"type\":\"audio\",\"field\":\"post_audios\",\"md5hash\":\"0179aa40f9b2982817d718bf9705fdde\",\"original_id\":\"c6ef3b40ca2311e3b45195d9609cd3b5\",\"original_basename\":\"Developers_converted\",\"original_md5hash\":\"0179aa40f9b2982817d718bf9705fdde\",\"url\":\"http://tmp.transloadit.com.s3.amazonaws.com/c6ef3b40ca2311e3b45195d9609cd3b5.mp3\",\"meta\":{\"duration\":8.624,\"audio_bitrate\":56000,\"overall_bitrate\":null,\"audio_samplerate\":44100,\"audio_channels\":2,\"audio_codec\":\"mp3\",\"encoder\":null,\"beats_per_minute\":null,\"album\":null,\"year\":null,\"genre\":null,\"artist\":null,\"comment\":null,\"performer\":null,\"lyrics\":null,\"title\":null,\"band\":null,\"disc\":null,\"track\":null}}],\":original\":[{\"id\":\"c6ef3b40ca2311e3b45195d9609cd3b5\",\"name\":\"Developers_converted.mp3\",\"basename\":\"Developers_converted\",\"ext\":\"mp3\",\"size\":60413,\"mime\":\"audio/mpeg\",\"type\":\"audio\",\"field\":\"post_audios\",\"md5hash\":\"0179aa40f9b2982817d718bf9705fdde\",\"original_id\":\"c6ef3b40ca2311e3b45195d9609cd3b5\",\"original_basename\":\"Developers_converted\",\"original_md5hash\":\"0179aa40f9b2982817d718bf9705fdde\",\"url\":\"s1y5uslj4plb.cloudfront.net/c5a3a870ca2311e3839773efa7db3d59____Developers_converted.mp3\",\"meta\":{\"duration\":8.624,\"audio_bitrate\":56000,\"overall_bitrate\":null,\"audio_samplerate\":44100,\"audio_channels\":2,\"audio_codec\":\"mp3\",\"encoder\":null,\"beats_per_minute\":null,\"album\":null,\"year\":null,\"genre\":null,\"artist\":null,\"comment\":null,\"performer\":null,\"lyrics\":null,\"title\":null,\"band\":null,\"disc\":null,\"track\":null},\"ssl_url\":\"https://s1y5uslj4plb.cloudfront.net/c5a3a870ca2311e3839773efa7db3d59____Developers_converted.mp3\"}]}}", "params"=>"{\"steps\":{\"files\":{\"robot\":\"/file/filter\",\"accepts\":[[\"${file.mime}\",\"regex\",\"audio\"]],\"error_on_decline\":true},\"store\":{\"robot\":\"/s3/store\",\"key\":\"AKIAJ5KUIYFXQB5KUD5A\",\"secret\":\"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\",\"use\":\":original\",\"url_prefix\":\"s1y5uslj4plb.cloudfront.net/\",\"bucket\":\"buddy-video-assets\",\"path\":\"${assembly.id}____${file.url_name}\"}},\"auth\":{\"key\":\"6742a710a9ab11e3a661690b776b09a8\",\"expires\":\"2014/04/22 14:11:11+00:00\"}}", "signature"=>"c13f114c7304c6a06de0779868102f6491ccc28d", "post_audios"=>"", "slug"=>"serg", "authenticity_token"=>"quOFW+WseZBbTN3eZLHGNbyABHpqL38V8CgTOUIIXrQ="}

describe AudiosController do
  let(:owner) { create_user email: 'owner@gmail.com', is_profile_owner: true }
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
    let(:audio_upload) { create_audios_upload(owner, transloadit: JSON.parse(transloadit_data['transloadit'])).first  }
    subject { delete 'destroy', id: audio_upload.id }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      before { sign_in owner }
      its(:status) { should == 200 }
    end
  end
end