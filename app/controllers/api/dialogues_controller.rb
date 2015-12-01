class Api::DialoguesController < Api::BaseController
  before_action :load_dialogue!, only: [:show, :destroy]

  protect(:index) { current_user.authorized? } # TODO (DJ): FIX IT
  protect(:show) { can? :see, @dialogue }
  protect(:destroy) { can? :manage, @dialogue }

  def index
    @dialogues = current_user.accessible_dialogues(params.slice(:page))
    json_success dialogues: api_response.dialogues_data(@dialogues), has_more: !current_user.dialogues.last_page?
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
