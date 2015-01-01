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

  flow :favorite do
    factory do
      attr(:offer).require
      attr(:user).map_to(performer)
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
