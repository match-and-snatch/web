class StaticPage < ApplicationRecord
  validates :slug, :content, presence: true
  validates :slug, uniqueness: {scope: :slug}
end
