class OffersController < ApplicationController
  before_filter :load_offer, only: [:show]

  popup :new do
    layout[:title] = 'New Offer'
  end

  def create
    pass_flow(flow.create_without_tags(params)) do
      json_redirect offer_path(flow.offer), notice: 'Successfully created new offer'
    end
  end

  def show
  end

  private

  def flow
    @flow ||= OfferFlow.new(performer: current_user, subject: @offer)
  end

  def load_offer
    @offer = Offer.find_by_id(params[:id]) or error(404)
  end
end