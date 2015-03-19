class Admin::PayoutBreakdownsController < Admin::BaseController
  def index
    # TODO (DJ): SIMPLIFY IT
    sql = <<-SQL.squish
      WITH events AS (SELECT user_id AS uid, MAX(created_at) as created
                      FROM subscription_daily_count_change_events
                      WHERE created_at BETWEEN '#{beginning_of_month}' AND '#{end_of_month}'
                      GROUP BY uid
                      ORDER BY created DESC),
      stat_events AS (SELECT *
                      FROM subscription_daily_count_change_events
                      INNER JOIN events
                      ON events.uid = subscription_daily_count_change_events.user_id
                      AND events.created = subscription_daily_count_change_events.created_at),
      pending_subs AS (SELECT subscriptions.target_user_id, COUNT(subscriptions.*) AS pending_count
                       FROM subscriptions
                       WHERE subscriptions.removed = 'f'
                       AND subscriptions.rejected = 'f'
                       AND (subscriptions.charged_at + INTERVAL '1 month') BETWEEN '#{beginning_of_month}' AND '#{end_of_month}'
                       GROUP BY subscriptions.target_user_id)

      SELECT
        users.*,
        stat_events.unsubscribers_count AS unsubscribers_count,
        pending_subs.pending_count AS pending_subs_count,
        COUNT(CASE
                WHEN (payments.created_at BETWEEN '#{beginning_of_month}' AND '#{end_of_month}')
                THEN 1
                ELSE NULL
              END) AS payments_count,
        SUM(CASE
                WHEN (payments.created_at BETWEEN '#{beginning_of_month}' AND '#{end_of_month}')
                THEN payments.cost
                ELSE 0
              END) AS payments_amount
      FROM users
      LEFT OUTER JOIN stat_events ON stat_events.user_id = users.id
      LEFT OUTER JOIN payments ON payments.target_user_id = users.id
      LEFT OUTER JOIN pending_subs ON pending_subs.target_user_id = users.id
      WHERE users.is_profile_owner = 't' AND users.subscription_cost IS NOT NULL AND subscribers_count > 0
      GROUP BY users.id, unsubscribers_count, pending_subs_count
      ORDER BY users.subscribers_count DESC
    SQL

    @users = User.find_by_sql(sql).map { |user| ProfileDecorator.new(user) }
    json_render
  end

  private

  def beginning_of_month
    Time.zone.now.beginning_of_month.to_s(:db)
  end

  def end_of_month
    Time.zone.now.end_of_month.to_s(:db)
  end
end
