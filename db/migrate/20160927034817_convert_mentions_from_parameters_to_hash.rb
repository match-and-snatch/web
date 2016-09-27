class ConvertMentionsFromParametersToHash < ActiveRecord::Migration[5.0]
  def change
    reversible do |direction|
      direction.up do
        execute <<-SQL.squish
          UPDATE comments
          SET mentions = REPLACE (mentions, ' !ruby/hash:ActionController::Parameters', '')
          WHERE mentions LIKE '%!ruby/hash:ActionController::Parameters%'
        SQL
      end
    end
  end
end
