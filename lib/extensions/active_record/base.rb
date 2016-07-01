module Extensions
  module ActiveRecord
    module Base
      def base_scope
        self
      end
    end
  end
end
