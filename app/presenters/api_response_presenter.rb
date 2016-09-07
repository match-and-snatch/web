class ApiResponsePresenter
  include MarkdownHelper
  include ActionView::Helpers::DateHelper
  include Rails.application.routes.url_helpers

  attr_reader :current_user

  # @param current_user [CurrentUserDecorator]
  def initialize(current_user)
    @current_user = current_user
  end

  # @param user [User]
  def basic_current_user_data(user = current_user.object)
    lock_type = case user.lock_type.try(:to_sym)
                  when :billing, :weekly_contribution_limit
                    :billing
                  else
                    user.lock_type
                  end

    {
      banned: user.locked? || user.cc_declined?,
      locked: user.locked?,
      lock_type: lock_type,
      tos_accepted: user.tos_accepted?,
      show_tos_popup: !(user.tos_accepted? || !TosVersion.active.try(:requires_acceptance?)),
      total_subscriptions_count: user.subscriptions_count,
      billing_failed: user.billing_failed?
    }
  end

  # @param user [User]
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
      cover_picture_position_perc: user.cover_picture_position_perc,
      cover_picture_height: user.cover_picture_height,
      has_complete_profile: user.has_complete_profile?,
      has_public_profile: user.has_public_profile?,
      has_profile_page: user.has_profile_page?,
      complete_profile: user.complete_profile?,
      profile_disabled: user.profile_disabled?,
      profile_enabled: user.profile_enabled?,
      passed_profile_steps: user.passed_profile_steps?,
      profile_name: user.profile_name,
      is_staff: user.staff?,
      contacts_info: user.contacts_info,
      cost: user.cost,
      subscription_fees: user.subscription_fees,
      subscription_cost: user.subscription_cost,
      cost_changed_at: user.cost_changed_at,
      company_name: user.company_name,
      small_account_picture_url: user.small_account_picture_url,
      original_account_picture_url: user.original_account_picture_url,
      activated: user.activated,
      notifications_debug_enabled: user.notifications_debug_enabled,
      message_notifications_enabled: user.message_notifications_enabled,
      rss_enabled: user.rss_enabled,
      downloads_enabled: user.downloads_enabled,
      itunes_enabled: user.itunes_enabled,
      profile_types_text: user.profile_types_text,
      subscribers_count: user.subscribers_count,
      subscriptions_count: user.subscriptions.accessible.count,
      only_subscription_path: user.subscriptions.accessible.count == 1 ? user.subscriptions.accessible.first.target_user.slug : nil,
      recurring_contributions_count: user.contributions.recurring.count,
      stripe_recipient_id: user.stripe_recipient_id,
      vacation_enabled: user.vacation_enabled,
      vacation_message: user.vacation_message,
      vacation_enabled_at: user.vacation_enabled_at,
      last_visited_profile_id: user.last_visited_profile_id,
      contributions_enabled: user.contributions_enabled,
      registration_token: user.registration_token,
      auth_token: user.auth_token,
      api_token: user.api_token,
      gross_threshold_reached: user.gross_threshold_reached?,
      cost_approved: user.cost_approved?,
      cc_declined: user.cc_declined?
    }.merge(account_data(user)).merge(basic_current_user_data(user))
  end

  # @param subscriptions [SubscriptionsPresenter]
  # @param contributions [Array]
  def billing_information_data(subscriptions: , contributions: [])
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
      cost: subscription.total_cost,
      notifications_enabled: subscription.notifications_enabled,
      created_at: subscription.created_at.to_date.to_s(:long),
      timestamp: subscription.created_at.to_i,
      target_user: user_data(subscription.target_user)
    }
  end

  def subscriptions_data(subscriptions = [])
    {}.tap do |data|
      subscriptions.each do |subscription|
        data[subscription.id] = subscription_data(subscription)
      end
    end
  end

  def post_data(post)
    {
      id: post.id,
      type: post.type,
      title: post.title,
      message: post.message,
      timestamp: post.created_at.to_i,
      created_at: time_ago_in_words(post.created_at),
      comments_count: post.comments_count,
      pinned: post.pinned?,
      uploads: post.uploads.map { |upload|
        upload_data(upload)
      },
      likes: {
        total_count: post.likes_count,
        liked: current_user.likes?(post)
      },
      profile: basic_profile_data(post.user)
    }
  end

  def comment_data(comment, include_replies: true)
    {
      id: comment.id,
      message: comment.message,
      timestamp: comment.created_at.to_i,
      created_at: time_ago_in_words(comment.created_at),
      hidden: comment.hidden,
      mentions: comment.mentions,
      parent_id: comment.parent_id,
      post_id: comment.post_id,
      post_user_id: comment.post_user_id,
      user_id: comment.user_id,
      post: {
        profile: basic_profile_data(comment.post.user)
      },
      access: {
        owner: current_user.id == comment.user_id,
        post_owner: current_user.id == comment.post_user_id
      },
      user: {
        id: comment.user.id,
        slug: comment.user.slug,
        name: comment.user.name,
        small_account_picture_url: comment.user.small_account_picture_url,
        small_profile_picture_url: comment.user.small_profile_picture_url,
        has_profile: comment.user.has_profile_page?
      },
      profile: {
        slug: comment.user.slug,
        name: comment.user.name,
        has_profile: comment.user.has_profile_page?
      },
      replies: [],
      likes: {
        total_count: comment.likes_count,
        liked: current_user.likes?(comment)
      }
    }.tap do |data|
      if include_replies && comment.replies_count > 0
        data[:replies] = comment.replies.map do |reply|
          comment_data(reply, include_replies: false)
        end
      end
    end
  end

  def dialogues_data(dialogues = [])
    {}.tap do |data|
      dialogues.each do |dialogue|
        data_for_dialogue = dialogue_data(dialogue)
        data[dialogue.id] = data_for_dialogue if data_for_dialogue
      end
    end
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
        recent_message_at: dialogue.recent_message_at.to_i,
        unread: dialogue.unread? && dialogue.recent_message.user != current_user.object
      }
    end
  end

  def messages_data(messages = [])
    messages.map { |message| message_data(message) }
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

  def mentions_data(users = [])
    users.map do |user|
      {
        id: user.id,
        name: user.name,
        slug: user.slug,
        small_account_picture_url: user.small_account_picture_url,
        small_profile_picture_url: user.small_profile_picture_url
      }
    end
  end

  def profile_data(user)
    {
      types: user.profile_types.order(:ordering).map(&:title),
      benefits: user.benefits_visible? ? user.benefits.order(:ordering).map(&:message) : [],
      benefits_visible: user.benefits_visible?,
      subscription_cost: user.subscription_cost,
      cost: user.cost,
      profile_picture_url: user.profile_picture_url,
      small_profile_picture_url: user.small_profile_picture_url,
      cover_picture_url: user.cover_picture_url,
      cover_picture_position: user.cover_picture_position,
      cover_picture_position_perc: user.cover_picture_position_perc,
      cover_picture_height: user.cover_picture_height,
      rss_enabled: user.rss_enabled?,
      vacation_enabled: user.vacation_enabled?,
      vacation_message: user.vacation_message,
      contributions_enabled: user.contributions_allowed?,
      has_mature_content: user.has_mature_content?,
      cost_approved: user.cost_approved?,
      welcome_media: {
        welcome_audio: welcome_media_data(user.welcome_audio, visible: user.welcome_media_visible?),
        welcome_video: welcome_media_data(user.welcome_video, visible: user.welcome_media_visible?),
        welcome_media_visible: user.welcome_media_visible?
      },
      custom_welcome_message: user.profile_page_data.welcome_box,
      special_offer_message: user.profile_page_data.special_offer,
      locked: user.locked?,
      dialogue_id: user.dialogues.by_user(current_user.object).first.try(:id)
    }.merge(basic_profile_data(user))
  end

  def basic_profile_data(user)
    {
      access: {
        owner: current_user.id == user.id,
        subscribed: subscribed_to?(user),
        billing_failed: current_user.billing_failed?,
        public_profile: user.has_public_profile?
      },
      id: user.id,
      name: user.name,
      slug: user.slug,
      small_account_picture_url: user.small_account_picture_url,
      small_profile_picture_url: user.small_profile_picture_url,
      has_profile: user.has_profile_page?,
      downloads_enabled: user.downloads_enabled?,
      itunes_enabled: user.itunes_enabled?
    }
  end

  def profile_details_data
    user = UserStatsDecorator.new(current_user.object)
    {
      subscribers_count: user.subscriptions_count,
      monthly_earnings: user.monthly_earnings,
      contributions: contributions_data
    }
  end

  def account_data(user)
    {
      active_subscriptions_count: user.subscriptions.active.count,
      account_picture_url: user.account_picture_url,
      billing_address_line_1: user.billing_address_line_1,
      billing_address_line_2: user.billing_address_line_2,
      billing_address_city: user.billing_address_city,
      billing_address_state: user.billing_address_state,
      billing_address_zip: user.billing_address_zip,
      billing_failed: user.billing_failed,
      billing_failed_at: user.billing_failed_at,
      email: user.email,
      full_name: user.full_name,
      has_cc_payment_account: user.has_cc_payment_account?,
      is_profile_owner: user.is_profile_owner?,
      last_four_cc_numbers: user.last_four_cc_numbers,
      slug: user.slug
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
      vacation_enabled: user.vacation_enabled?,
      contributions_enabled: user.contributions_allowed?,
      accepts_large_contributions: user.accepts_large_contributions?,
      has_mature_content: user.has_mature_content?
    }
  end

  def profiles_list_data(top_users = [], users = {})
    {
      top_profiles: top_users.map do |user|
        user_data(user).tap do |data|
          data[:types] = user.top_profile.types
          data[:name] = user.top_profile.name
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

  def audios_data(audios = [])
    (audios.any? ? audios : current_user.pending_audios).map { |audio| audio_data(audio) }
  end

  def welcome_media_data(upload, visible: true)
    return {} unless visible
    return {} unless upload

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
                       hdfile_url: upload.hd_rtmp_path,
                       playlist_url: playlist_url
                   }
                 else
                   {}
                 end
    common_data.merge(video_data)
  end

  def tos_data
    {terms_of_service: markdown_to_html(TosVersion.active.try(:tos) || '')}
  end

  def privacy_policy_data
    {privacy_policy: markdown_to_html(TosVersion.active.try(:privacy_policy) || '')}
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
      retina_preview_url: upload.retina_preview_url,
      original_url: upload.original_url,
      url: upload.url,
      ordering: upload.ordering
    }.tap do |data|
      if upload.video?
        data[:hdfile_url] = upload.hd_rtmp_path
        data[:playlist_url] = (upload.low_quality_playlist_url ? playlist_video_url(upload.id, format: 'm3u8', host: 'https://www.connectpal.com') : nil)
      end
    end
  end

  def audio_data(audio)
    {
      id: audio.id,
      filename: audio.filename
    }
  end

  def subscribed_to?(target)
    return false if current_user.id == target.id

    @st_cache ||= {}
    @st_cache[target.id] ||= current_user.subscribed_to?(target)
  end
end
