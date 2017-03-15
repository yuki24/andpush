module RoboMsg
  class Result
    attr_reader :message_id, :registration_id, :error

    def initialize(message_id: nil, registration_id: nil, error: nil)
      @message_id = message_id
      @registration_id = registration_id
      @error = error
    end
  end
end
