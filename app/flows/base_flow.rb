class BaseFlow < Flows::Base
  def self.protect(*actions, &block)
    if block
      add_before_callback(actions) do
        instance_eval(&block) or raise AccessError
      end
    else
      if actions.present?
        actions.each do |action|
          add_before_callback([action]) do
            Ability.new(performer).can?(action, subject) or raise AccessError
          end
        end
      else
        raise ArgumentError, 'Missing actions list'
      end
    end
  end
end