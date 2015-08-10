class SitemapsController < ApplicationController
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
  end
end
