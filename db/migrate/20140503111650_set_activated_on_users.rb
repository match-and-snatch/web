class SetActivatedOnUsers < ActiveRecord::Migration
  def up
    User.update_all(activated: true)
  end

  def down
    User.update_all(activated: false)
  end
end
