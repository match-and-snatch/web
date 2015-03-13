class TopProfile < ActiveRecord::Base
  belongs_to :user
  scope :ordered, -> { order(:position, :created_at) }

  # Rebuilds list of top user profiles
  # @param user_ids [Array<Ingeter, String>]
  def self.update_list(user_ids)
    user_ids.each_with_index do |user_id, index|
      where(user_id: user_id).update_all(position: index)
    end
  end
end
