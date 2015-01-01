class AddMessagesEnabledToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :messages_enabled, :boolean
  end
end
