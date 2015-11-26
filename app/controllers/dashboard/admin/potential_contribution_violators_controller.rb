class Dashboard::Admin::PotentialContributionViolatorsController < Dashboard::Admin::BaseController

  def index
    @months = Contribution
      .joins("INNER JOIN contributions cs
              ON date_trunc('month', cs.created_at) = date_trunc('month', contributions.created_at)
                AND contributions.user_id = cs.user_id
                AND contributions.id <> cs.id".squish)
      .group("date_trunc('month', contributions.created_at)")
      .having('COUNT(cs.id) >= 5')
      .count('DISTINCT(contributions.user_id)')
      .to_a.sort_by(&:first)

    @date = Chronic.parse(params[:month]) || Time.zone.now

    @users = User
      .joins(:contributions)
      .includes(contributions: :target_user)
      .where("contributions.created_at BETWEEN ? AND ? ", @date.beginning_of_month, @date.end_of_month)
      .group('users.id')
      .having('COUNT(contributions.id) >= 5')
      .order('users.created_at DESC')
      .page(params[:page]).per(20)

    json_render
  end
end
