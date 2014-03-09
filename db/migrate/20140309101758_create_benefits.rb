class CreateBenefits < ActiveRecord::Migration
  def change
    create_table :benefits do |t|
      t.text :message
      t.references :user
    end
  end
end
