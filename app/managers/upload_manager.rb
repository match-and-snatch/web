class UploadManager < BaseManager
  attr_reader :user

  # @param user [User]
  def initialize(user)
    @user = user
  end

  # @param transloadit_data [Hash]
  # @return [Upload]
  def create_pending_video(transloadit_data)
    create(transloadit_data, attributes: {uploadable_type: 'Post', uploadable_id: nil})
  end

  # @param transloadit_data [Hash]
  # @return [Upload]
  def create_pending_photo(transloadit_data)
    create(transloadit_data, attributes: {uploadable_type: 'Post', uploadable_id: nil})
  end

  # @param transloadit_data [Hash]
  # @param uploadable [ActiveRecord::Base]
  # @param attributes [Hash] upload attributes
  # @return [Upload]
  def create(transloadit_data, uploadable: user, attributes: {})
    upload = Upload.new transloadit_data: transloadit_data,
                        uploadable: uploadable,
                        user_id: user.id,
                        type: transloadit_data["uploads"][0]["type"],
                        duration: transloadit_data["uploads"][0]["meta"]["duration"],
                        mime_type: transloadit_data["uploads"][0]["mime"]
    upload.attributes = attributes
    upload.save or fail_with! upload.errors
    upload
  end
end