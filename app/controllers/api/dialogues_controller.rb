class Api::DialoguesController < Api::BaseController
  before_action :load_dialogue!, only: [:show, :destroy]

  protect(:index) { current_user.authorized? } # TODO (DJ): FIX IT
  protect(:show) { can? :see, @dialogue }
  protect(:destroy) { can? :manage, @dialogue }

  def index
    @dialogues = current_user.object.dialogues.not_removed.
        includes(recent_message: :user).order(recent_message_at: :desc).limit(200).to_a
    json_success @dialogues.map { |dialogue| dialogue_data(dialogue) }
  end

  def show
    @dialogue = MessagesManager.new(user: current_user.object, dialogue: @dialogue).mark_as_read
    json_success dialogue_data(@dialogue).merge(messages: messages_data(@dialogue.messages))
  end

  def destroy
    MessagesManager.new(user: current_user.object, dialogue: @dialogue).remove
    json_success
  end

  private

  def load_dialogue!
    @dialogue = Dialogue.where(id: params[:id]).first or error(404)
  end

  def dialogue_data(dialogue)
    antiuser = dialogue.antiuser(current_user.object)
    {
      id: dialogue.id,
      antiuser: {
        id: antiuser.id,
        name: antiuser.name,
        slug: antiuser.slug,
        picture_url: antiuser.comment_picture_url,
        has_complete_profile: antiuser.has_complete_profile
      },
      recent_message: dialogue.recent_message.message,
      recent_message_at: dialogue.recent_message_at,
      recent_message_contribution: dialogue.recent_message.contribution.present?,
      recent_mesasge_sent_by_me: dialogue.recent_message.user == current_user.object,
      unread: dialogue.unread?
    }
  end

  def messages_data(messages = [])
    messages.recent.map do |message|
      {
        id: message.id,
        created_at: message.created_at,
        message: message.message,
        contribution: message.contribution.present?,
        user: {
          name: message.user.name,
          picture_url: message.user.comment_picture_url
        }
      }
    end
  end
end
