require 'robo_msg/models/response'
require 'robo_msg/models/result'
require 'robo_msg/models/error_response'

module RoboMsg
  OBJECT_MAP = {
    Response => {
      results: Array(Result)
    },
    Result => {
    },
    ErrorResponse => {
    }
  }.freeze
end
