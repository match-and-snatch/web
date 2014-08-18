require_relative '../../lib/action_controller/manageble_parameters'
class SetCreatedAtFieldsOnUploads < ActiveRecord::Migration
  def up
    Upload.find_each do |upload|
      if upload.uploadable.try(:respond_to?, :created_at) && upload.created_at.nil?
        upload.created_at = upload.uploadable.created_at
      end
      upload.transloadit_data = upload.transloadit_data.to_hash
      upload.save!
    end
    Upload.where(created_at: nil).update_all(created_at: Time.zone.now)
  end

  def down
  end
end
