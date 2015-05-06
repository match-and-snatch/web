class AccountInfo::LogsController < AccountInfo::BaseController

  def index
    @logs = wrap(current_user.object.events.order('created_at DESC').limit(200))
    json_render
  end

  private

  def wrap(events)
    events.map do |event|
      LogEventDecorator.new(event)
    end
  end

  class LogEventDecorator < Struct.new(:event)
    delegate :id, :message, :data, to: :event

    def time
      event.created_at.to_s(:long)
    end

    def action
      event.action.humanize
    end
  end
end
