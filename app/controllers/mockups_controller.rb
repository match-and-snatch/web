class MockupsController < ApplicationController

  def show
    render "mockups/#{params[:mockup]}"
  end
end