class Api::DocumentsController < Api::UploadsController
  def create
    documents = manager.create_pending_documents(params[:transloadit])
    json_success documents_data(documents)
  end

  private

  def documents_data(documents)
    { documents: documents.map { |document| document_data(document) } }
  end

  def document_data(document)
    {
      id: document.id
    }
  end
end
