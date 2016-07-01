class AddSubjectDeletedFlagToEvents < ActiveRecord::Migration
  def change
    add_column :events, :subject_deleted, :boolean, default: false, null: false
    add_index :events, :subject_deleted
  end
end
