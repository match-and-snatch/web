class DocumentsController < UploadsController

  def create
    manager.create_pending_documents(params[:transloadit])
    json_replace partial: 'document_posts/pending_uploads'
  end

  def destroy
    super
    json_render partial: 'document_posts/pending_uploads'
  end
end
