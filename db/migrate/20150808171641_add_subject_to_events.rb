class AddSubjectToEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.references :subject, polymorphic: true
    end
  end
end
