class AddDataFieldInJsonbFormatToEvents < ActiveRecord::Migration
  def change
    enable_extension 'citext'

    rename_column :events, :data, :old_data
    add_column :events, :data, :jsonb, null: false, default: '{}'
  end
end
