# frozen_string_literal: true

require 'uri'
require 'base64'
require 'singleton'

require 'grpc'

module LNDClientInternal
  class Connector
    include Singleton

    def initialize
      @connections = {}
    end

    def self.expand(*params)
      return exapand_lndconnect(*params) if is_lndconnect?(*params)

      params.first
    end

    def self.exapand_lndconnect(*params)
      parsed_uri = URI.parse(params.first)
      host = parsed_uri.host
      port = parsed_uri.port || 10_009

      params = URI.decode_www_form(parsed_uri.query).to_h
      certificate = params['cert'].tr('-_', '+/')
      macaroon = Base64.urlsafe_decode64(params['macaroon']).unpack1('H*')

      certificate = "-----BEGIN CERTIFICATE-----\n" +
                 certificate.gsub(/(.{64})/, "\\1\n") +
                 "\n-----END CERTIFICATE-----\n"

      {
        host: host,
        port: port,
        certificate: certificate,
        macaroon: macaroon
      }
    end

    def self.is_lndconnect?(*params)
      params.is_a?(Array) &&
        params.size == 1 &&
        params[0].is_a?(String) &&
        params.first.start_with?('lndconnect://')
    end

    def for(id)
      @connections[id]
    end

    def register(id, credentials)
      expanded = Connector.expand(credentials)
      expanded[:address] = "#{expanded[:host]}:#{expanded[:port]}"
      expanded[:credentials] = ::GRPC::Core::ChannelCredentials.new(expanded[:certificate])
      @connections[id] = expanded
    end

    def load_certificate(path, &vcr)
      load_file(path, &vcr)
    end

    def load_macaroon(path, &vcr)
      raw = load_file(path, &vcr)

      raw.unpack1('H*')
    end

    private

    def load_file(path, &vcr)
      vcr.nil? ? File.read(path) : vcr.call(-> { File.read(path) })
    end
  end
end
