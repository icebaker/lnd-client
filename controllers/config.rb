# frozen_string_literal: true

require 'grpc'

module LNDClientInternal
  class ConfigController
    attr_reader :socket_address, :credentials, :certificate, :macaroon

    def initialize(client, options)
      @client = client

      @certificate_path = options[:certificate_path]
      @certificate = options[:certificate]

      @macaroon_path = options[:macaroon_path]
      @macaroon = options[:macaroon]

      @socket_address = options[:socket_address] || '127.0.0.1:10009'

      setup_certificate!
      setup_macaroon!
    end

    def setup_certificate!
      raise 'conflicting options for certificate' if @certificate && @certificate_path

      @certificate = File.read(@certificate_path) if @certificate_path
      @credentials = ::GRPC::Core::ChannelCredentials.new(@certificate)
    end

    def setup_macaroon!
      raise 'conflicting options for macaroon' if @macaroon && @macaroon_path

      @macaroon = File.read(@macaroon_path).unpack('H*') if @macaroon_path
    end
  end
end
