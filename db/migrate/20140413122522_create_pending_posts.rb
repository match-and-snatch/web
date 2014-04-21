class CreatePendingPosts < ActiveRecord::Migration
  def change
    create_table :pending_posts do |t|
      t.references :user
      t.string :title, limit: 512
      t.text :message
      t.text :keywords
    end
  end
end
