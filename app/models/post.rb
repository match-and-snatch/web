class Post < ActiveRecord::Base
  include PgSearch

  belongs_to :user
  has_many :comments

  pg_search_scope :search_by_message, against: :message,
                                      using: [:tsearch, :dmetaphone, :trigram],
                                      ignoring: :accents
end
