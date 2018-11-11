require 'net/http/persistent'

require 'andpush/version'
require 'andpush/client'

module Andpush
  DOMAIN = 'https://fcm.googleapis.com'.freeze

  class << self
    def build(server_key, domain: nil, name: nil, proxy: nil, pool_size: Net::HTTP::Persistent::DEFAULT_POOL_SIZE)
      ::Andpush::Client
        .new(domain || DOMAIN, request_handler: ConnectionPool.new(name: name, proxy: proxy, pool_size: pool_size))
        .register_interceptor(Authenticator.new(server_key))
    end
    alias new build

    def http2(server_key, domain: nil)
      begin
        require 'curb' if !defined?(Curl)
      rescue LoadError => error
        raise LoadError, "Could not load the curb gem. Make sure to install the gem by running:\n\n" \
                         "  $ gem i curb\n\n" \
                         "Or the Gemfile has the following declaration:\n\n" \
                         "  gem 'curb'\n\n" \
                         "  (#{error.class}: #{error.message})"
      end

      ::Andpush::Client
        .new(domain || DOMAIN, request_handler: Http2RequestHandler.new)
        .register_interceptor(Authenticator.new(server_key))
    end
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

  class Http2RequestHandler
    BY_HEADER_LINE   = /[\r\n]+/.freeze
    HEADER_VALUE     = /^(\S+): (.+)/.freeze
    EMPTY_HEADERS    = {}.freeze

    attr_reader :multi

    def initialize(max_connects: 100)
      @multi = Curl::Multi.new

      @multi.pipeline     = Curl::CURLPIPE_MULTIPLEX if defined?(Curl::CURLPIPE_MULTIPLEX)
      @multi.max_connects = max_connects
    end

    def call(request_class, uri, headers, body, *_)
      easy = Curl::Easy.new(uri.to_s)

      easy.multi       = @multi
      easy.headers     = headers || EMPTY_HEADERS
      easy.post_body   = body if request_class::REQUEST_HAS_BODY

      if defined?(Curl::CURLPIPE_MULTIPLEX)
        # This ensures libcurl waits for the connection to reveal if it is
        # possible to pipeline/multiplex on before it continues.
        easy.setopt(Curl::CURLOPT_PIPEWAIT, 1)
        easy.version = Curl::HTTP_2_0
      end

      easy.public_send(:"http_#{request_class::METHOD.downcase}")

      Response.new(
        Hash[easy.header_str.split(BY_HEADER_LINE).flat_map {|s| s.scan(HEADER_VALUE) }],
        easy.body,
        easy.response_code.to_s, # to_s for compatibility with Net::HTTP
        easy,
      ).freeze
    end

    Response = Struct.new(:headers, :body, :code, :raw_response) do
      alias to_hash headers
    end

    private_constant :BY_HEADER_LINE, :HEADER_VALUE, :Response
  end

  private_constant :Authenticator, :ConnectionPool, :Http2RequestHandler
end
