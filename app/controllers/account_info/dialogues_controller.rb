class AccountInfo::DialoguesController < AccountInfo::BaseController
  before_filter :load_dialogue!, only: [:mark_as_read]

  def index
    @dialogues = Dialogue.by_user(current_user.object).includes(recent_message: :user).order('recent_message_at DESC').limit(200).to_a
    json_render
  end

  def mark_as_read
    MessagesManager.new(user: current_user.object).mark_as_read(@dialogue)
    json_replace html: render_to_string(partial: 'dialogue', locals: {dialogue: @dialogue})
  end

  private

  def load_dialogue!
    @dialogue = Dialogue.find(params[:id])
  end
end