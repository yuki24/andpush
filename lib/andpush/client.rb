# frozen-string-literal: true
require 'net/http'
require 'andpush/exceptions'
require 'andpush/json_handler'

module Andpush
  class Client
    attr_reader :domain, :proxy_addr, :proxy_port, :proxy_user, :proxy_password, :request_handler

    def initialize(domain, proxy_addr: nil, proxy_port: nil, proxy_user: nil, proxy_password: nil, request_handler: RequestHandler.new, **options)
      @domain = domain
      @proxy_addr = proxy_addr
      @proxy_port = proxy_port
      @proxy_user = proxy_user
      @proxy_password = proxy_password
      @interceptors = []
      @observers = []
      @request_handler = request_handler
      @options = DEFAULT_OPTIONS.merge(options)

      register_interceptor(JsonSerializer.new)
      register_observer(ResponseHandler.new)
      register_observer(JsonDeserializer.new)
    end

    def register_interceptor(interceptor)
      @interceptors << interceptor
      self
    end

    def register_observer(observer)
      @observers << observer
      self
    end

    def push(body, query: {}, headers: {}, **options)
      request(Net::HTTP::Post, uri('/fcm/send', query), body, headers, method: :push, **options)
    end

    private

    DEFAULT_OPTIONS = {
      ca_file: nil,
      ca_path: nil,
      cert: nil,
      cert_store: nil,
      ciphers: nil,
      close_on_empty_response: nil,
      key: nil,
      open_timeout: nil,
      read_timeout: nil,
      ssl_timeout: nil,
      ssl_version: nil,
      use_ssl: nil,
      verify_callback: nil,
      verify_depth: nil,
      verify_mode: nil
    }.freeze

    HTTPS = 'https'.freeze

    def request(request_class, uri, body, headers, options = {})
      uri, body, headers, options = @interceptors.reduce([uri, body, headers, @options.merge(options)]) { |r, i| i.before_request(*r) }

      response = begin
        request_handler.call(request_class, uri, headers, body, proxy_addr, proxy_port, proxy_user, proxy_password, options)
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
        raise NetworkError, "A network error occurred: #{e.class} (#{e.message})"
      end

      @observers.reduce(response) { |r, o| o.received_response(r, options) }
    end

    def uri(path, query = {})
      uri = URI.join(domain, path)
      uri.query = URI.encode_www_form(query) unless query.empty?
      uri
    end

    class RequestHandler
      def call(request_class, uri, headers, body, proxy_addr, proxy_port, proxy_user, proxy_password, options = {})
        Net::HTTP.start(uri.host, uri.port, proxy_addr, proxy_port, proxy_user, proxy_password, options, use_ssl: (uri.scheme == HTTPS)) do |http|
          http.request request_class.new(uri, headers), body
        end
      end
    end

    private_constant :RequestHandler
  end
end
