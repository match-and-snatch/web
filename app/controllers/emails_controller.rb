class EmailsController < ApplicationController
  layout false

  def show
    render "emails/#{params[:mockup]}"
  end
end
