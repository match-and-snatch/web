class OfferFlow < Flow
  subject :offer

  factory do
    attr(:title).require
    attr(:user).map_to(performer)
  end

  action :add_to_favorites do
    flows.favorite.create offer: offer
  end

  flow :favorite do
    subject :favorite

    factory do
      attr(:offer).require
      attr(:user).map_to(performer)
    end
  end
end