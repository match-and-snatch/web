class MockupsController < ApplicationController

  def show
    respond_to do |format|
      format.html do
        render "mockups/#{params[:mockup]}"
      end

      format.json do
        json_render template: params[:mockup]
      end
    end
  end
end