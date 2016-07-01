class String
  include Extensions::String
end

class ActiveRecord::Base
  extend Extensions::ActiveRecord::Base
end
