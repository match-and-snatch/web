class AccountInfo::DialoguesController < AccountInfo::BaseController
  before_filter :load_dialogue!, only: [:show, :confirm_removal, :destroy]

  protect(:show) { can? :see, @dialogue }
  protect(:destroy) { can? :manage, @dialogue }

  def index
    @dialogues = Dialogue.by_user(current_user.object).not_removed.
      includes(recent_message: :user).order('recent_message_at DESC').limit(200).to_a
    json_render
  end

  def show
    json_render.tap { MessagesManager.new(user: current_user.object, dialogue: @dialogue).mark_as_read }
  end

  def confirm_removal
    json_popup
  end

  def destroy
    MessagesManager.new(user: current_user.object, dialogue: @dialogue).remove
    json_replace
  end

  private

  def load_dialogue!
    @dialogue = Dialogue.where(id: params[:id]).first or error(404)
  end
end
