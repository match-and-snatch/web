class BaseLogger
  delegate :payload, :performer, :subject, :name, :created_at, to: :@source_event

  def self.log(*event_names, &block)
    event_names.each do |event_name|
      ::Flows::Subscriber.subscribe(event_name) do |source_event|
        ::BaseLogger.new(source_event).log(&block)
      end
    end
  end

  # @param source_event [Flows::Event]
  def initialize(source_event)
    @source_event = source_event
  end

  def log(&block)
    event = Event.new(user: performer,
                      action: name,
                      subject_id: subject_record.try(:id),
                      subject_type: subject_record.try(:class).try(:name),
                      data: data,
                      created_at: created_at)

    instance_exec(event, &block)
    event.save!
  end

  protected

  def data
    {}
  end

  private

  # @return [ActiveRecord::Base, nil]
  def subject_record
    subject if subject.is_a?(ActiveRecord::Base)
  end
end
