require 'object_mapper'

module Andpush
  class ObjectConverter
    METHOD_TO_CLASS_MAP = {
      push: Response
    }.freeze

    def received_response(response, method: nil, **)
      if method && response.respond_to?(:parsable?) && response.parsable? && METHOD_TO_CLASS_MAP[method]
        ObjectResponse.new(response, METHOD_TO_CLASS_MAP[method])
      else
        response
      end
    end
  end

  class ObjectResponse < DelegateClass(JsonResponse)
    OBJECT_MAPPER = ::ObjectMapper.new(OBJECT_MAP)

    def initialize(response, target_class)
      super(response)
      @target_class = target_class
    end

    def object
      OBJECT_MAPPER.convert(json, to: @target_class)
    end
    alias body_as_object object
  end

  private_constant :ObjectConverter, :ObjectResponse
end
