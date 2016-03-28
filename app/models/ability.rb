class Ability
  attr_reader :performer

  # @param performer [User]
  def initialize(performer)
    @performer = performer
  end

  # @param action [Symbol]
  # @param subject
  # @raise [ArgumentError] if action or subject are not registered
  # @return [true, false]
  def can?(action, subject)
    return false if performer.locked?

    case subject
      when Dialogue
        subject.users.where(users: {id: performer.id}).any?
      when User
        case action
          when :login_as             then performer.staff?
          when :subscribe_to         then subject.id != performer.id && authorized? && !subscribed_to?(subject) && !billing_failed?
          when :see_subscribe_button then subject.id != performer.id &&                !subscribed_to?(subject) && !billing_failed?
          when :see                  then subject.id == performer.id ||                 subscribed_to?(subject) || subject.has_public_profile?
          when :manage               then subject.id == performer.id
          when :send_message_to      then subscribed_to?(subject) && !billing_failed?
          else
            raise ArgumentError, "No such action #{action}"
        end
      when Upload
        case action
          when :manage then subject.user_id == performer.id
        end
      when Comment
        case action
          when :create, :toggle_like then subject.post_user_id == performer.id || performer.subscribed_to?(subject.post_user)
          when :show, :hide, :remove, :update then subject.user == performer || subject.post_user_id == performer.id
          when :delete, :manage then subject.user_id == performer.id || subject.post_user_id == performer.id
          when :like            then subject.user_id == performer.id || subject.post_user_id == performer.id || subscribed_to?(subject.post_user)
          else
            raise ArgumentError, "No such action #{action}"
        end
      when Post
        case action
          when :see             then performer.id == subject.user_id || subscribed_to?(subject.user) || subject.user.has_public_profile?
          when :delete, :manage then performer.id == subject.user_id
          when :like, :comment  then performer.id == subject.user_id || subscribed_to?(subject.user)
          else
            raise ArgumentError, "No such action #{action}"
        end
      when Contribution
        case action
          when :make   then subscribed_to?(subject.target_user)
          when :delete then performer.id == subject.user_id
          else
            raise ArgumentError, "No such action #{action}"
        end
      when Subscription
        case action
          when :delete then performer.id == subject.user_id
          else
            raise ArgumentError, "No such action #{action}"
        end
      else
        raise ArgumentError, "No such subject #{subject.inspect}"
    end
  end

  private

  def subscribed_to?(target)
    @st_cache ||= {}
    @st_cache[target.id] ||= performer.subscribed_to?(target)
  end

  def billing_failed?
    performer.billing_failed?
  end
end
