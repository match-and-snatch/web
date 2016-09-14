class TopProfile < ApplicationRecord
  belongs_to :user
  scope :ordered, -> { order(:position, :created_at) }

  # Rebuilds list of top user profiles
  # @param user_ids [Array<Ingeter, String>]
  def self.update_list(user_ids)
    user_ids.each_with_index do |user_id, index|
      where(user_id: user_id).update_all(position: index)
    end
  end

  def profile_types_text=(val)
    write_attribute(:profile_types_text, val.try(:strip).presence)
  end

  # @return [String]
  def name
    profile_name.presence || user.profile_name
  end

  # @return [String]
  def types
    profile_types_text.presence || user.profile_types.first.try(:title)
  end
end
