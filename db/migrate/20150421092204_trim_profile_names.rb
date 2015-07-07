class TrimProfileNames < ActiveRecord::Migration
  def up
    update("update users set profile_name = trim(both ' ' from profile_name) where profile_name IS NOT NULL;")
  end

  def down
  end
end
