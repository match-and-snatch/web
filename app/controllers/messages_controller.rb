class MessagesController < ApplicationController
  before_filter :load_offer, only: [:create]

  def create
    pass_flow(flow.send_message(params[:content])) { json_reload }
  end

  private

  def flow
    @flow ||= OfferFlow.new(performer: current_user, subject: @offer)
  end

  def load_offer
    @offer = Offer.find_by_id(params[:offer_id]) or error(404)
  end
end