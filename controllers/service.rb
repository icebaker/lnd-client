# frozen_string_literal: true

require_relative './documentation'

module LNDClientInternal
  class ServiceController
    attr_reader :doc, :service

    def initialize(client, rpc, params = {})
      @client = client
      @rpc = rpc
      @service = rpc.const_get(:Service)
      @stub = rpc.const_get(:Stub).new(
        client.connection[:address],
        client.connection[:credentials],
        **params
      )
      @doc = LNDClientInternal::DocumentationController.new(@service)
    end

    def call!(method_key, desc, *args, &block)
      @stub.method(method_key).call(
        desc.input.new(*args),
        { metadata: { macaroon: @client.connection[:macaroon] } },
        &block
      )
    end

    def respond_to_missing?(method_name, include_private = false)
      desc = @doc.grpc(method_name)
      (desc && @stub.respond_to?(method_name)) || super
    end

    def method_missing(method_name, *args, &block)
      desc = @doc.grpc(method_name)

      raise ArgumentError, "Method `#{method_name}` doesn't exist." unless desc && @stub.respond_to?(method_name)

      call!(method_name, desc, *args, &block)
    end
  end
end
