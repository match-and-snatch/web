class Api::DocumentPostsController < Api::MediaPostsController
  def new
    json_success pending_document_post_data
  end
  
  def cancel
    manager.cancel_pending_documents
    json_success
  end

  protected

  def create_post
    manager.create_document_post(params.slice(%i(title keyword_text message)).merge({ notify: params.bool(:notify) }))
  end

  def pending_document_post_data
    document_post_data = {
      post_type: 'DocumentPost',
      documents: current_user.pending_documents.map { |document| document_data(document) }
    }
    pending_post_data.merge(document_post_data)
  end

  def document_data(document)
    {
      id: document.id
    }
  end
end
