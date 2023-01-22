# frozen_string_literal: true

require_relative '../components/grpc'
require_relative 'config'
require_relative 'service'

class ClientController
  attr_reader :config, :doc

  def initialize(options)
    @config = ConfigController.new(self, options)
    @services = {}

    doc = Struct.new(:services)
    @doc = doc.new(GRPC::SERVICES.keys.map(&:to_s))
  end

  def respond_to_missing?(method_name, include_private = false)
    service_key = method_name.to_sym

    GRPC::SERVICES.include?(service_key) || super
  end

  def method_missing(method_name, *_args)
    service_key = method_name.to_sym

    raise ArgumentError, "Method `#{method_name}` doesn't exist." unless GRPC::SERVICES.include?(service_key)

    @services[service_key] ||= ServiceController.new(self, GRPC::SERVICES[service_key])
  end
end
