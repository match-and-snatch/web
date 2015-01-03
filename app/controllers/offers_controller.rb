class OffersController < ApplicationController
  before_filter :load_offer, only: [:show, :destroy, :toggle_favorite, :like, :dislike]

  popup :new do
    layout[:title] = 'New Offer'
  end

  def create
    pass_flow(flow.create_without_tags(params)) do
      json_redirect offer_path(flow.offer), notice: 'Successfully created new offer'
    end
  end

  def show
    pass_flow(flow.hit)
  end

  def destroy
    pass_flow(flow.destroy) { json_reload }
  end

  def toggle_favorite
    pass_flow(flow.toggle_favorite) { json_reload }
  end

  def like
    pass_flow(flow.like) { json_reload }
  end

  def dislike
    pass_flow(flow.dislike) { json_reload }
  end

  private

  def flow
    @flow ||= OfferFlow.new(performer: current_user, subject: @offer)
  end

  def load_offer
    @offer = Offer.find_by_id(params[:id]) or error(404)
  end
end