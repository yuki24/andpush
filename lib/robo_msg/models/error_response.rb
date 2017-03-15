module RoboMsg
  class ErrorResponse
    attr_reader :operation, :notification_key_name, :notification_key, :registration_ids

    def initialize(operation: nil, notification_key_name: nil, notification_key: nil, registration_ids: nil)
      @operation = operation
      @notification_key_name = notification_key_name
      @notification_key = notification_key
      @registration_ids = registration_ids
    end
  end
end
