class ApiResponsePresenter
  include ActionView::Helpers::DateHelper
  include Rails.application.routes.url_helpers

  attr_reader :current_user

  def initialize(current_user)
    @current_user = current_user
  end

  def billing_information_data(subscriptions: [], contributions: [])
    {
      subscriptions: {
        show_status_column: subscriptions.show_failed_column?,
        active: subscriptions.active.map { |subscription| subscription_data(subscription) },
        canceled: subscriptions.canceled.map { |subscription| subscription_data(subscription) }
      },
      contributions: contributions.map do |contribution|
        {
          id: contribution.id,
          target_user: target_user_data(contribution.target_user),
          next_billing_date: contribution.next_billing_date.to_s(:long)
        }
      end
    }
  end

  def subscription_data(subscription)
    {
      id: subscription.id,
      billing_date: subscription.billing_date.to_s(:long),
      canceled_at: subscription.canceled_at ? subscription.canceled_at.to_s(:long) : nil,
      removed: subscription.removed?,
      rejected: subscription.rejected?,
      target_user: target_user_data(subscription.target_user)
    }
  end

  def subscriptions_data(subscriptions = [])
    subscriptions.map do |subscription|
      {
        id: subscription.id,
        cost: subscription.total_cost,
        notifications_enabled: subscription.notifications_enabled,
        created_at: subscription.created_at.to_date.to_s(:long),
        user: {
          profile_owner: subscription.target_user.is_profile_owner?,
          slug: subscription.target_user.slug,
          name: subscription.target_user.name,
          picture_url: subscription.target_user.profile_picture_url
        }
      }
    end
  end

  def post_data(post)
    {
      id: post.id,
      type: post.type,
      title: post.title,
      message: post.message,
      created_at: time_ago_in_words(post.created_at),
      uploads: post_uploads_data(post),
      user: user_data(post.user),
      likes: post.likers_data.merge(liked: current_user.likes?(post))
    }
  end

  def comment_data(comment)
    {
      id: comment.id,
      message: comment.message,
      created_at: time_ago_in_words(comment.created_at),
      hidden: comment.hidden,
      mentions: comment.mentions,
      access: {
        owner: current_user == comment.user,
        post_owner: current_user == comment.post_user
      },
      user: {
        slug: comment.user.slug,
        name: comment.user.name,
        picture_url: comment.user.comment_picture_url,
        has_profile: comment.user.has_profile_page?
      },
      replies: comment.replies.map { |r| comment_data(r) },
      likes: comment.likers_data.merge(liked: current_user.likes?(comment))
    }
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
      recent_message_at: time_ago_in_words(dialogue.recent_message_at),
      recent_message_contribution: dialogue.recent_message.contribution.present?,
      recent_mesasge_sent_by_me: dialogue.recent_message.user == current_user.object,
      unread: dialogue.unread?
    }
  end

  def messages_data(messages = [])
    messages.recent.map do |message|
      {
        id: message.id,
        created_at: time_ago_in_words(message.created_at),
        message: message.message,
        contribution: message.contribution.present?,
        user: {
          name: message.user.name,
          picture_url: message.user.comment_picture_url
        }
      }
    end
  end

  private

  def user_data(user)
    {
      id: user.id,
      name: user.name,
      subscription_cost: user.subscription_cost,
      cost: user.cost,
      profile_picture_url: user.profile_picture_url,
      small_profile_picture_url: user.small_profile_picture_url,
      cover_picture_url: user.cover_picture_url,
      cover_picture_position: user.cover_picture_position,
      downloads_enabled: user.downloads_enabled?,
      itunes_enabled: user.itunes_enabled?,
      rss_enabled: user.rss_enabled?,
      vacation_enabled: user.vacation_enabled?
    }
  end

  def target_user_data(user)
    {
      id: user.id,
      slug: user.slug,
      name: user.name,
      is_profile_owner: user.is_profile_owner?,
      vacation_enabled: user.vacation_enabled?
    }
  end

  def post_uploads_data(post)
    post.uploads.map do |upload|
      common_data = {
        id: upload.id,
        filename: upload.filename,
        file_url: upload.rtmp_path,
        preview_url: upload.preview_url,
        original_url: upload.original_url
      }
      video_data = if upload.video?
                     playlist_url = if upload.low_quality_playlist_url
                                      playlist_video_url(upload.id, format: 'm3u8', host: 'https://www.connectpal.com')
                                    end
                     {
                       hdfile_url:   upload.hd_rtmp_path,
                       playlist_url: playlist_url
                     }
                   else
                     {}
                   end
      common_data.merge(video_data)
    end
  end
end
