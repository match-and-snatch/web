class AddTitleAndKeywordsToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :title, :string, limit: 512
    add_column :posts, :keywords_text, :string, limit: 512
  end
end
