class Dashboard::Admin::MatureProfilesController < Dashboard::Admin::BaseController
  before_action :load_user!, only: [:confirm_hide_welcome_media, :hide_welcome_media,
                                    :confirm_show_welcome_media, :show_welcome_media]

  def index
    query = User.profile_owners.where(has_mature_content: true)

    query = case params[:filter]
              when 'welcome_media_visible'
                query.where(welcome_media_hidden: false)
              when 'welcome_media_hidden'
                query.where(welcome_media_hidden: true)
              else
                query
            end

    @users = query.order(subscribers_count: :desc).page(params[:page]).per(100)
    json_render
  end

  def confirm_hide_welcome_media
    json_popup
  end

  def hide_welcome_media
    manager.hide_welcome_media
    json_reload
  end

  def confirm_show_welcome_media
    json_popup
  end

  def show_welcome_media
    manager.show_welcome_media
    json_reload
  end

  def bulk_toggle_welcome_media_visibility
    case params[:commit]
      when 'hide'
        Concerns::WelcomeMediaHandler.hide_welcome_media(params[:ids])
      when 'show'
        Concerns::WelcomeMediaHandler.show_welcome_media(params[:ids])
      else
        error(400)
    end
    json_reload
  rescue BulkEmptySetError => e
    json_reload notice: e.message
  end

  private

  def manager
    UserProfileManager.new(@user)
  end

  def load_user!
    @user = User.find(params[:id])
  end
end
