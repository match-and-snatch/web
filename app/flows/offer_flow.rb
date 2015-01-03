class OfferFlow < Flow
  factory do
    attr(:title).require
    attr(:user).map_to(performer)
    attr(:tag_ids).array.require(:missing_tag)
    attr(:messages_enabled).boolean
    attr(:calls_enabled).boolean
  end

  factory :without_tags do
    attr(:title).require
    attr(:user).map_to(performer)
    attr(:messages_enabled).boolean
    attr(:calls_enabled).boolean
  end

  action :add_to_favorites do
    flows.favorite(offer_favorite).create offer: offer
  end

  action :remove_from_favorites do
    flows.favorite(offer_favorite).destroy
  end

  action :toggle_favorite do
    offer.favorited_by?(performer) ? remove_from_favorites : add_to_favorites
  end

  action :like do
    offer_feedback.try(:destroy)
    flows.feedback.create offer: offer, positive: true
  end

  action :dislike do
    offer_feedback.try(:destroy)
    flows.feedback.create offer: offer, positive: false
  end

  action :subscribe do
    flows.subscription.create offer: offer
  end

  action :hit do
    offer.hits_count += 1
    save
  end

  action :send_message do |content|
    flows.message.create offer: offer, content: content
  end

  action :send_reply do |parent_id:, content:|
    flows.message.create_reply offer: offer, content: content, parent_id: parent_id
  end

  action :destroy do
    offer.destroy
  end

  flow :favorite do
    factory do
      attr(:offer).require
      attr(:user).map_to(performer)
    end

    action :destroy do
      favorite.destroy
    end
  end

  flow :feedback do
    factory do
      attr(:offer).require
      attr(:user).map_to(performer)
      attr(:positive).boolean.require
    end
  end

  flow :message do
    factory do
      attr(:offer).require
      attr(:content).require
      attr(:user).map_to(performer)
    end

    factory :reply do
      attr(:offer).require
      attr(:content).require
      attr(:user).map_to(performer)
      attr(:parent_id).require
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

  private

  def offer_favorite
    @offer_favorite ||= offer.favorites.find_by_user_id(performer.id)
  end

  def offer_feedback
    @offer_feedback ||= offer.feedbacks.find_by_user_id(performer.id)
  end
end
