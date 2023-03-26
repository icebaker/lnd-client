# frozen_string_literal: true

require 'uri'
require 'base64'
require 'singleton'

require 'grpc'

require_relative '../models/errors'

module LNDClientInternal
  class Connection
    def self.validate_params!(connection)
      if connection.key?(:address) && !connection[:address].nil? && connection.key?(:host) && connection[:host].nil?
        raise LNDClient::Errors::TooManyArgumentsError
      end

      if connection.key?(:address) && !connection[:address].nil? && connection.key?(:port) && !connection[:port].nil?
        raise LNDClient::Errors::TooManyArgumentsError
      end

      if connection.key?(:certificate_path) && !connection[:certificate_path].nil? && connection.key?(:certificate) && !connection[:certificate].nil?
        raise LNDClient::Errors::TooManyArgumentsError
      end

      if connection.key?(:macaroon_path) && !connection[:macaroon_path].nil? && connection.key?(:macaroon) && !connection[:macaroon].nil?
        raise LNDClient::Errors::TooManyArgumentsError
      end
    end

    def self.expand(*params, &vcr)
      connection = if is_lndconnect?(*params)
                     exapand_lndconnect(*params)
                   else
                     params.first
                   end

      validate_params!(connection)

      connection[:certificate] = load_file(connection[:certificate_path], &vcr) if connection[:certificate_path]

      connection[:macaroon] = load_file(connection[:macaroon_path], &vcr) if connection[:macaroon_path]

      if !connection.key?(:address) && connection.key?(:host) && connection.key?(:port)
        connection[:address] = "#{connection[:host]}:#{connection[:port]}"
      elsif !connection.key?(:address)
        raise LNDClient::Errors::ArgumentError, 'missing :address or :host + :port'
      end

      connection[:certificate] = decode_certificate(connection[:certificate])
      connection[:macaroon] = decode_macaroon(connection[:macaroon])

      if params.is_a?(Array)
        params.each do |param|
          connection[:lightning] = param[:lightning] if param.is_a?(Hash) && param.key?(:lightning)
        end
      end

      connection
    end

    def self.decode_macaroon(macaroon)
      if !macaroon.dup.force_encoding(Encoding::UTF_8).valid_encoding?
        macaroon.unpack1('H*')
      elsif hex?(macaroon)
        macaroon
      elsif base64?(macaroon)
        Base64.decode64(macaroon).unpack1('H*')
      end
    end

    def self.decode_certificate(certificate)
      if hex?(certificate)
        [certificate].pack('H*')
      elsif base64?(certificate)
        Base64.decode64(certificate)
      else
        certificate
      end
    end

    def self.base64?(value)
      (value.length % 4).zero? && value.match(%r{\A[A-Za-z0-9+/]+={0,3}\z})
    end

    def self.hex?(value)
      value.match(/\A[\da-fA-F]+\z/)
    end

    def self.exapand_lndconnect(*params)
      parsed_uri = URI.parse(params.first)
      host = parsed_uri.host
      port = parsed_uri.port || 10_009

      params = URI.decode_www_form(parsed_uri.query).to_h
      certificate = params['cert'].tr('-_', '+/')
      macaroon = Base64.urlsafe_decode64(params['macaroon'])

      padding_needed = 4 - (certificate.length % 4)
      certificate += '=' * padding_needed

      certificate = "-----BEGIN CERTIFICATE-----\n#{certificate.gsub(/(.{64})/, "\\1\n")}\n-----END CERTIFICATE-----\n"

      {
        connect: params.first,
        host: host,
        port: port,
        certificate: certificate,
        macaroon: macaroon
      }
    end

    def self.is_lndconnect?(*params)
      params.is_a?(Array) &&
        params.first.is_a?(String) &&
        params.first.start_with?('lndconnect://')
    end

    def self.standalone(*params, &vcr)
      connection = Connection.expand(*params, &vcr)
      connection[:credentials] = ::GRPC::Core::ChannelCredentials.new(connection[:certificate])
      connection
    end

    def self.load_file(path, &vcr)
      vcr.nil? ? File.read(path) : vcr.call(-> { File.read(path) }, path)
    end
  end
end
