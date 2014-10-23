class DocumentPostsController < PendingPostsController

  def cancel
    PostManager.new(user: current_user.object).cancel_pending_documents
    json_render template: 'new'
  end

  protected

  def create_post
    PostManager.new(user: current_user.object).create_document_post(params.slice(%i(title keyword_text message)).merge({ notify: params.bool(:notify) }))
  end

  def cancel_media_posts_path
    cancel_document_posts_path
  end

  def media_posts_path
    document_posts_path
  end
  helper_method :media_posts_path, :cancel_media_posts_path
end

