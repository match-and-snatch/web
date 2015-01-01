class OfferFlow < Flow
  factory do
    attr(:title).require
    attr(:user).map_to(performer)
    attr(:tag_ids).array.require(:missing_tag)
  end

  factory :without_tags do
    attr(:title).require
    attr(:user).map_to(performer)
  end

  action :add_to_favorites do
    flows.favorite.create offer: offer
  end

  action :like do
    flows.feedback.create offer: offer, positive: true
  end

  action :dislike do
    flows.feedback.create offer: offer, positive: false
  end

  action :subscribe do
    flows.subscription.create offer: offer
  end

  flow :favorite do
    factory do
      attr(:offer).require
      attr(:user).map_to(performer)
    end
  end

  flow :feedback do
    factory do
      attr(:offer).require
      attr(:user).map_to(performer)
      attr(:positive).boolean.require
    end
  end

  flow :subscription do
    factory do
      attr(:offer).require
      attr(:user).map_to(performer)
      attr(:query).map_to -> { offer.title }
      attr(:tag_ids).map_to -> { offer.tag_ids }
    end
  end

  update do
    attr(:title).require
    attr(:tag_ids).array.require(:missing_tag)
  end

  update :tags do
    attr(:tag_ids).array.require(:missing_tag)
  end
end
