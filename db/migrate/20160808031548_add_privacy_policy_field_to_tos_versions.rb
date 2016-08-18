class AddPrivacyPolicyFieldToTosVersions < ActiveRecord::Migration
  def change
    reversible do |direction|
      direction.up do
        add_column :tos_versions, :privacy_policy, :text

        pp_text = File.exist?('public/privacy_policy.txt') ? File.read('public/privacy_policy.txt') : ''
        TosVersion.update_all(privacy_policy: pp_text)
      end

      direction.down do
        remove_column :tos_versions, :privacy_policy
      end
    end
  end
end
