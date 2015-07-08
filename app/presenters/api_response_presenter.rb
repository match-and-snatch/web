class ApiResponsePresenter
  include ActionView::Helpers::DateHelper
  include Rails.application.routes.url_helpers

  attr_reader :current_user

  def initialize(current_user)
    @current_user = current_user
  end

  def current_user_data(user = current_user.object)
    {
      id: user.id,
      created_at: user.created_at,
      updated_at: user.updated_at,
      holder_name: user.holder_name,
      routing_number: user.routing_number,
      account_number: user.account_number,
      prefer_paypal: user.prefers_paypal?,
      paypal_email: user.paypal_email,
      stripe_user_id: user.stripe_user_id,
      stripe_card_id: user.stripe_card_id,
      has_cc_payment_account: user.has_cc_payment_account?,
      card_type: user.card_type,
      profile_picture_url: user.profile_picture_url,
      small_profile_picture_url: user.small_profile_picture_url,
      original_profile_picture_url: user.original_profile_picture_url,
      cover_picture_url: user.cover_picture_url,
      original_cover_picture_url: user.original_cover_picture_url,
      cover_picture_position: user.cover_picture_position,
      has_complete_profile: user.has_complete_profile?,
      has_public_profile: user.has_public_profile?,
      has_profile_page: user.has_profile_page?,
      complete_profile: user.complete_profile?,
      profile_disabled: user.profile_disabled?,
      profile_enabled: user.profile_enabled?,
      passed_profile_steps: user.passed_profile_steps?,
      profile_name: user.profile_name,
      is_admin: user.is_admin,
      contacts_info: user.contacts_info,
      cost: user.cost,
      subscription_fees: user.subscription_fees,
      subscription_cost: user.subscription_cost,
      cost_changed_at: user.cost_changed_at,
      company_name: user.company_name,
      small_account_picture_url: user.small_account_picture_url,
      original_account_picture_url: user.original_account_picture_url,
      comment_picture_url: user.comment_picture_url,
      activated: user.activated,
      notifications_debug_enabled: user.notifications_debug_enabled,
      rss_enabled: user.rss_enabled,
      downloads_enabled: user.downloads_enabled,
      itunes_enabled: user.itunes_enabled,
      profile_types_text: user.profile_types_text,
      subscribers_count: user.subscribers_count,
      subscriptions_count: user.subscriptions.active.count,
      recurring_contributions_count: user.contributions.where(recurring: true).count,
      billing_failed: user.billing_failed,
      billing_failed_at: user.billing_failed_at,
      stripe_recipient_id: user.stripe_recipient_id,
      vacation_enabled: user.vacation_enabled,
      vacation_message: user.vacation_message,
      vacation_enabled_at: user.vacation_enabled_at,
      last_visited_profile_id: user.last_visited_profile_id,
      contributions_enabled: user.contributions_enabled,
      registration_token: user.registration_token,
      auth_token: user.auth_token,
      api_token: user.api_token
    }.merge(account_data(user))
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
          target_user: user_data(contribution.target_user),
          next_billing_date: contribution.next_billing_date.to_s(:long)
        }
      end
    }
  end

  def subscription_data(subscription)
    {
      id: subscription.id,
      billing_date: subscription.billing_date.to_s(:long),
      canceled_at: subscription.canceled_at ? subscription.canceled_at.to_date.to_s(:long) : nil,
      removed: subscription.removed?,
      rejected: subscription.rejected?,
      target_user: user_data(subscription.target_user)
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
          picture_url: subscription.target_user.profile_picture_url,
          small_profile_picture_url: subscription.target_user.small_profile_picture_url
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
      uploads: post.uploads.map { |upload| upload_data(upload) },
      user: user_data(post.user),
      likes: post.likers_data.merge(liked: current_user.likes?(post)),
      comments_count: post.comments.count,
      access: {
        owner: post.user == current_user.object
      }
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
    if antiuser = dialogue.antiuser(current_user.object)
      {
        id: dialogue.id,
        antiuser: {
          id: antiuser.id,
          name: antiuser.name,
          slug: antiuser.slug,
          picture_url: antiuser.comment_picture_url,
          has_profile_page: antiuser.has_profile_page?
        },
        recent_message: message_data(dialogue.recent_message),
        unread: dialogue.unread? && dialogue.recent_message.user != current_user.object
      }
    end
  end

  def messages_data(messages = [])
    messages.recent.map { |message| message_data(message) }
  end

  def message_data(message)
    {
      id: message.id,
      created_at: time_ago_in_words(message.created_at),
      message: message.message,
      dialogue_id: message.dialogue_id,
      contribution: contribution_data(message.contribution),
      user: {
        name: message.user.name,
        picture_url: message.user.comment_picture_url
      }
    }
  end

  def profile_details_data
    user = UserStatsDecorator.new(current_user)
    {
      subscribers_count: user.subscriptions_count,
      monthly_earnings: user.monthly_earnings,
      contributions: contributions_data
    }
  end

  def account_data(user)
    {
      slug: user.slug,
      is_profile_owner: user.is_profile_owner?,
      full_name: user.full_name,
      email: user.email,
      account_picture_url: user.account_picture_url,
      billing_address_line_1: user.billing_address_line_1,
      billing_address_line_2: user.billing_address_line_2,
      billing_address_city: user.billing_address_city,
      billing_address_state: user.billing_address_state,
      billing_address_zip: user.billing_address_zip,
      last_four_cc_numbers: user.last_four_cc_numbers
    }
  end

  def profile_settings_data(user)
    {
      cost: user.cost,
      contributions_enabled: user.contributions_enabled,
      downloads_enabled: user.downloads_enabled,
      itunes_enabled: user.itunes_enabled,
      rss_enabled: user.rss_enabled,
      profile_name: user.profile_name,
      vacation_enabled: user.vacation_enabled,
      holder_name: user.holder_name,
      routing_number: user.routing_number,
      account_number: user.account_number,
      prefer_paypal: user.prefers_paypal?,
      paypal_email: user.paypal_email,
      benefits: user.benefits.order(:ordering).pluck(:message),
      profile_types: user.profile_types.map { |profile_type| profile_type_data(profile_type) },
      welcome_video: upload_data(user.welcome_video)
    }
  end

  def user_data(user)
    {
      id: user.id,
      slug: user.slug,
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
      is_profile_owner: user.is_profile_owner?,
      vacation_enabled: user.vacation_enabled?
    }
  end

  def profiles_list_data(top_users = [], users = {})
    {
      top_profiles: top_users.map do |user|
        user_data(user).tap do |data|
          data[:types] = user.profile_types.order(:ordering).map(&:title)
        end
      end,
      profiles: users.each do |k, v|
        users[k] = v.map { |user| user_data(user) }
      end
    }
  end

  def contribution_data(contribution = nil)
    {}.tap do |data|
      if contribution
        data[:contributor_name] = contribution.user.name
        data[:created_at] = contribution.created_at.to_s(:short)
        data[:recurring] = contribution.recurring?
        data[:amount] = contribution.amount
      end
    end
  end

  def profile_type_data(profile_type)
    {
      id: profile_type.id,
      title: profile_type.title
    }
  end

  def pending_video_data(video)
    {
      id: video.try(:id),
      previews: current_user.object.pending_video_preview_photos(true).first(2).map do |preview|
        {
          id: preview.id,
          url: preview.url
        }
      end
    }
  end

  private

  def contributions_data
    { total_amount: 0, contributions: [] }.tap do |data|
      contributions = Contribution.where(target_user_id: current_user.id)
      if contributions.any?
        data[:total_amount] = contributions.total_amount
        data[:contributions].concat(contributions.each_year_month.map do |year_month, contributions|
          {
            date: year_month.to_s,
            count: contributions.count,
            amount: contributions.sum(&:amount)
          }
        end)
      end
    end
  end

  def upload_data(upload)
    return {} unless upload

    {
      id: upload.id,
      filename: upload.filename,
      file_url: upload.rtmp_path,
      preview_url: upload.preview_url,
      original_url: upload.original_url,
      url: upload.url
    }.tap do |data|
      if upload.video?
        data[:hdfile_url] = upload.hd_rtmp_path
        data[:playlist_url] = (upload.low_quality_playlist_url ? playlist_video_url(upload.id, format: 'm3u8', host: 'https://www.connectpal.com') : nil)
      end
    end
  end
end
