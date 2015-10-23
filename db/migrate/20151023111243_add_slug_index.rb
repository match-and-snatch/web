class AddSlugIndex < ActiveRecord::Migration
  def change
    add_index(:users, :slug, using: 'hash')
  end
end
