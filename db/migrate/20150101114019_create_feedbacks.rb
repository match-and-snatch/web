class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.boolean :positive
      t.references :offer
      t.references :user
      t.timestamps null: false
    end
  end
end
