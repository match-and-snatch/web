class SitemapsController < ApplicationController
  def show
    respond_to do |wants|
      wants.xml do
        @public_profiles = User.profile_owners.with_complete_profile
      end
    end
  end
end
