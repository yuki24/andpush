require 'andpush/version'
require 'andpush/client'

module Andpush
  DOMAIN = 'https://fcm.googleapis.com'.freeze

  def self.build(server_key, domain: nil)
    ::Andpush::Client
      .new(domain || DOMAIN)
      .register_interceptor(Authenticator.new(server_key))
  end

  class Authenticator
    def initialize(server_key)
      @server_key = server_key
    end

    def before_request(uri, body, headers, options)
      headers['Authorization'] = "key=#{@server_key}"

      [uri, body, headers, options]
    end
  end
end
