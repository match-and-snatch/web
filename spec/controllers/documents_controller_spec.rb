require 'spec_helper'

transloadit_data = {"transloadit"=>"{\"ok\":\"ASSEMBLY_COMPLETED\",\"message\":\"The assembly was successfully completed.\",\"assembly_id\":\"ac03e030ca2611e3ad989d7c0e8dc643\",\"parent_id\":null,\"assembly_url\":\"http://api2.ifrah.transloadit.com/assemblies/ac03e030ca2611e3ad989d7c0e8dc643\",\"bytes_received\":73317,\"bytes_expected\":73317,\"client_agent\":\"Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36\",\"client_ip\":\"80.64.83.135\",\"client_referer\":\"http://localhost:3001/serg\",\"start_date\":\"2014/04/22 14:02:00 GMT\",\"is_infinite\":false,\"has_dupe_jobs\":false,\"upload_duration\":1.443,\"execution_start\":\"2014/04/22 14:02:02 GMT\",\"execution_duration\":2.92,\"notify_start\":null,\"notify_url\":null,\"notify_status\":null,\"last_job_completed\":\"2014/04/22 14:02:05 GMT\",\"notify_duration\":null,\"fields\":{\"slug\":\"serg\"},\"running_jobs\":[],\"bytes_usage\":7232,\"executing_jobs\":[],\"started_jobs\":[],\"files_to_store_on_s3\":0,\"queued_files_to_store_on_s3\":0,\"parent_assembly_status\":null,\"params\":\"{\\\"steps\\\":{\\\"files\\\":{\\\"robot\\\":\\\"/file/filter\\\",\\\"accepts\\\":[[\\\"${file.name}\\\",\\\"regex\\\",\\\".+[^\\\\\\\\.(exe|bin|dll|js|sh|bash|rb|py)]$\\\"]],\\\"error_on_decline\\\":true},\\\"store\\\":{\\\"robot\\\":\\\"/s3/store\\\",\\\"key\\\":\\\"****\\\",\\\"secret\\\":\\\"****\\\",\\\"use\\\":\\\":original\\\",\\\"bucket\\\":\\\"buddy-private-assets\\\",\\\"path\\\":\\\"uploads/post_documents/${fields.slug}/${assembly.id}/${file.url_name}\\\"}}}\",\"uploads\":[{\"id\":\"ad863a70ca2611e395b037db04dd3c0c\",\"name\":\"Codility.pdf\",\"basename\":\"Codility\",\"ext\":\"pdf\",\"size\":72317,\"mime\":\"application/pdf\",\"type\":\"pdf\",\"field\":\"post_documents\",\"md5hash\":\"ae13512d0f6ecfc632034d1f5f0e24d7\",\"original_id\":\"ad863a70ca2611e395b037db04dd3c0c\",\"original_basename\":\"Codility\",\"original_md5hash\":\"ae13512d0f6ecfc632034d1f5f0e24d7\",\"url\":\"http://tmp.ifrah.transloadit.com/upload/be4d2ecd43f511b94606bcd383537a31.pdf\",\"meta\":{\"page_count\":2,\"title\":null,\"author\":null,\"producer\":null,\"creator\":null,\"create_date\":null,\"modify_date\":null}}],\"last_seq\":3,\"results\":{\"files\":[{\"id\":\"ad863a70ca2611e395b037db04dd3c0c\",\"name\":\"Codility.pdf\",\"basename\":\"Codility\",\"ext\":\"pdf\",\"size\":72317,\"mime\":\"application/pdf\",\"type\":\"pdf\",\"field\":\"post_documents\",\"md5hash\":\"ae13512d0f6ecfc632034d1f5f0e24d7\",\"original_id\":\"ad863a70ca2611e395b037db04dd3c0c\",\"original_basename\":\"Codility\",\"original_md5hash\":\"ae13512d0f6ecfc632034d1f5f0e24d7\",\"url\":\"http://tmp.transloadit.com.s3.amazonaws.com/ad863a70ca2611e395b037db04dd3c0c.pdf\",\"meta\":{\"page_count\":2,\"title\":null,\"author\":null,\"producer\":null,\"creator\":null,\"create_date\":null,\"modify_date\":null}}],\":original\":[{\"id\":\"ad863a70ca2611e395b037db04dd3c0c\",\"name\":\"Codility.pdf\",\"basename\":\"Codility\",\"ext\":\"pdf\",\"size\":72317,\"mime\":\"application/pdf\",\"type\":\"pdf\",\"field\":\"post_documents\",\"md5hash\":\"ae13512d0f6ecfc632034d1f5f0e24d7\",\"original_id\":\"ad863a70ca2611e395b037db04dd3c0c\",\"original_basename\":\"Codility\",\"original_md5hash\":\"ae13512d0f6ecfc632034d1f5f0e24d7\",\"url\":\"http://buddy-private-assets.s3.amazonaws.com/uploads/post_documents/serg/ac03e030ca2611e3ad989d7c0e8dc643/Codility.pdf\",\"meta\":{\"page_count\":2,\"title\":null,\"author\":null,\"producer\":null,\"creator\":null,\"create_date\":null,\"modify_date\":null},\"ssl_url\":\"https://buddy-private-assets.s3.amazonaws.com/uploads/post_documents/serg/ac03e030ca2611e3ad989d7c0e8dc643/Codility.pdf\"}]}}", "params"=>"{\"steps\":{\"files\":{\"robot\":\"/file/filter\",\"accepts\":[[\"${file.name}\",\"regex\",\".+[^\\\\.(exe|bin|dll|js|sh|bash|rb|py)]$\"]],\"error_on_decline\":true},\"store\":{\"robot\":\"/s3/store\",\"key\":\"AKIAJ5KUIYFXQB5KUD5A\",\"secret\":\"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\",\"use\":\":original\",\"bucket\":\"buddy-private-assets\",\"path\":\"uploads/post_documents/${fields.slug}/${assembly.id}/${file.url_name}\"}},\"auth\":{\"key\":\"6742a710a9ab11e3a661690b776b09a8\",\"expires\":\"2014/04/22 14:31:42+00:00\"}}", "signature"=>"a069a3694804f9106e204b35042ca746a7c1a0ca", "post_documents"=>"", "slug"=>"serg", "authenticity_token"=>"quOFW+WseZBbTN3eZLHGNbyABHpqL38V8CgTOUIIXrQ="}

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
    let(:document_upload) { create_documents_upload(owner, transloadit: JSON.parse(transloadit_data['transloadit'])).first  }
    subject { delete 'destroy', id: document_upload.id }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      before { sign_in owner }
      its(:status) { should == 200 }
    end
  end
end