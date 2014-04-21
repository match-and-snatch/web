class ProfileType < ActiveRecord::Base
  include PgSearch

  has_many :profile_types_users, dependent: :delete_all
  has_many :users, through: :profile_types_users

  pg_search_scope :search_by_title, against: :title,
                                    using: [:tsearch, :dmetaphone, :trigram],
                                    ignoring: :accents
end