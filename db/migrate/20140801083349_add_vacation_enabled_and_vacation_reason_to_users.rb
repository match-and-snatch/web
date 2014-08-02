class AddVacationEnabledAndVacationReasonToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.boolean :vacation_enabled, default: false, null: false
      t.text :vacation_reason
    end
  end
end
