module Concerns::PublicProfileHandler

  protected

  def load_public_user!
    @target_user or raise NotImplementedError
  end

  # @overload
  def process_http_code_error(error)
    case error.code
    when 401
      load_public_user!
      template = current_user.authorized? ? '/subscriptions/new' : '/subscriptions/new_unauthorized'
      json_popup popup: render_to_string(template: template, layout: false)
    else
      super
    end
  end
end
