class DocumentsController < UploadsController

  def create
    manager.create_pending_documents(params[:transloadit])
    json_replace template: 'document_posts/pending_uploads'
  end

  def destroy
    super
    json_render template: 'document_posts/pending_uploads'
  end
end
