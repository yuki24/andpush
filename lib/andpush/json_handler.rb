require 'json'
require 'delegate'

module Andpush
  class JsonResponse < DelegateClass(Net::HTTPResponse)
    alias response __getobj__
    alias headers to_hash
    HAS_SYMBOL_GC = RUBY_VERSION > '2.2.0'

    def json
      parsable? ? JSON.parse(body, symbolize_names: HAS_SYMBOL_GC) : nil
    end

    def inspect
      "#<JsonResponse response: #{response.inspect}, json: #{json}>"
    end
    alias to_s inspect

    def parsable?
      !!body && !body.empty?
    end
  end

  class JsonSerializer
    APPLICATION_JSON     = 'application/json'.freeze
    JSON_REQUEST_HEADERS = {
      'Content-Type' => APPLICATION_JSON,
      'Accept'       => APPLICATION_JSON
    }.freeze

    def before_request(uri, body, headers, options)
      headers = headers.merge(JSON_REQUEST_HEADERS)
      body    = body.nil? || body.is_a?(String) ? body : body.to_json

      [uri, body, headers, options]
    end
  end

  class JsonDeserializer
    def received_response(response, _options)
      JsonResponse.new(response)
    end
  end

  private_constant :JsonSerializer, :JsonDeserializer
end
