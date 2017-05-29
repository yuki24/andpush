require 'net/http/persistent'

require 'andpush/version'
require 'andpush/client'

module Andpush
  DOMAIN = 'https://fcm.googleapis.com'.freeze

  def self.build(server_key, domain: nil, request_handler: ConnectionPool.new)
    ::Andpush::Client
      .new(domain || DOMAIN, request_handler: request_handler)
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

  class ConnectionPool
    attr_reader :connection

    def initialize(name: nil, proxy: nil, pool_size: Net::HTTP::Persistent::DEFAULT_POOL_SIZE)
      @connection = Net::HTTP::Persistent.new(name: name, proxy: proxy, pool_size: pool_size)
    end

    def call(request_class, uri, headers, body, *_)
      req = request_class.new(uri, headers)
      req.set_body_internal(body)

      connection.request(uri, req)
    end
  end

  private_constant :Authenticator, :ConnectionPool
end
