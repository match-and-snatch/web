class AddContributionIdToMessages < ActiveRecord::Migration
  def change
    change_table :messages do |t|
      t.references :contribution
    end
  end
end
