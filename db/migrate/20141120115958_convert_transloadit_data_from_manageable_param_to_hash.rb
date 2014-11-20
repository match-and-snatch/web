class ConvertTransloaditDataFromManageableParamToHash < ActiveRecord::Migration
  def change
    reversible do |direction|
      direction.up do
        execute <<-SQL.squish
          UPDATE uploads
          SET transloadit_data = REPLACE (transloadit_data, ' !ruby/hash:ActionController::ManagebleParameters', '')
          WHERE transloadit_data LIKE '%!ruby/hash:ActionController::ManagebleParameters%'
        SQL
      end
    end
  end
end
