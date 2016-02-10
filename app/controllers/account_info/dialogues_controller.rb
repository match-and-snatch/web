class AccountInfo::DialoguesController < AccountInfo::BaseController
  before_action :load_dialogue!, only: [:show, :confirm_removal, :destroy]

  protect(:show) { can? :see, @dialogue }
  protect(:destroy) { can? :manage, @dialogue }

  def index
    @dialogues = current_user.accessible_dialogues(params.slice(:page))
    params[:page] ? json_replace(partial: 'dialogues_list') : json_render
  end

  def show
    json_render.tap { MessagesManager.new(user: current_user.object, dialogue: @dialogue).mark_as_read }
  end

  def confirm_removal
    json_popup
  end

  def destroy
    MessagesManager.new(user: current_user.object, dialogue: @dialogue).remove
    current_user.accessible_dialogues.any? ? json_replace : json_replace(partial: 'no_messages_label')
  end

  private

  def load_dialogue!
    @dialogue = Dialogue.where(id: params[:id]).first or error(404)
  end
end
