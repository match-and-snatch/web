class SitemapsController < ApplicationController
  respond_to :xml

  def show
    @public_profiles = User.profile_owners.with_complete_profile
  end
end