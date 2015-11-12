class SitemapsController < ApplicationController
  caches_action :index, expires_in: 1.hour
  before_action :load_public_profiles!

  def show
    respond_to do |wants|
      wants.xml
    end
  end

  def sitemap_mobile
    respond_to do |wants|
      wants.xml
    end
  end

  private

  def load_public_profiles!
    @public_profiles = User.profile_owners.with_complete_profile
                         .where("(users.hidden = 'f' AND users.has_mature_content = 'f')")
  end
end
