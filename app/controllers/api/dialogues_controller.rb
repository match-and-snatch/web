class Api::DialoguesController < Api::BaseController
  before_action :load_dialogue!, only: [:show, :destroy]

  protect(:index) { current_user.authorized? } # TODO (DJ): FIX IT
  protect(:show) { can? :see, @dialogue }
  protect(:destroy) { can? :manage, @dialogue }

  def index
    @dialogues = current_user.dialogues.not_removed.
        includes(recent_message: :user).order(recent_message_at: :desc).limit(200).to_a
    json_success dialogues: api_response.dialogues_data(@dialogues)
  end

  def show
    @dialogue = MessagesManager.new(user: current_user.object, dialogue: @dialogue).mark_as_read
    json_success dialogue: api_response.dialogue_data(@dialogue).merge(messages: api_response.messages_data(@dialogue.messages.recent))
  end

  def destroy
    MessagesManager.new(user: current_user.object, dialogue: @dialogue).remove
    json_success dialogue: api_response.dialogue_data(@dialogue)
  end

  private

  def load_dialogue!
    @dialogue = Dialogue.where(id: params[:id]).first or error(404)
  end
end
