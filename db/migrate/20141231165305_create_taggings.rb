class CreateTaggings < ActiveRecord::Migration
  def change
    create_table :offers_tags do |t|
      t.references :offer
      t.references :tag
    end
  end
end
