Kaminari.configure do |config|
  # config.default_per_page = 25
  # config.max_per_page = nil
  # config.window = 4
  # config.outer_window = 0
  # config.left = 0
  # config.right = 0
  # config.page_method_name = :page
  # config.param_name = :page
  config.params_on_first_page = true
end

# Slim support for pagination
module Kaminari
  module ActionViewExtension
    def paginate(scope, options = {})
      paginator = Kaminari::Helpers::Paginator.new(
        self,
        options.reverse_merge(current_page: scope.current_page,
                              total_pages: scope.total_pages,
                              per_page: scope.limit_value,
                              remote: false)
      )
      paginator.output_buffer = ActionView::OutputBuffer.new
      paginator.to_s
    end
  end
end
