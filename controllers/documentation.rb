# frozen_string_literal: true

require_relative '../logic/string'

module LNDClientInternal
  class DocumentationController
    attr_reader :available_methods

    def initialize(service)
      @service = service
      @descriptions = {}
      @grpc = {}

      build!
    end

    def build!
      @available_methods = @service.service.rpc_descs.values.map do |desc|
        method_name = LNDClientInternal::StringLogic.underscore(desc.name.to_s)

        build_description!(method_name, desc)

        @grpc[method_name] = desc

        method_name
      end.sort
    end

    def build_description!(method_name, desc)
      input = desc.input.new.to_h if desc.input.respond_to?(:new)
      output = desc.output.new.to_h if desc.output.respond_to?(:new)

      @descriptions[method_name] = { method: method_name }

      @descriptions[method_name][:input] = input if input
      @descriptions[method_name][:output] = output if output
    end

    def describe(method_name)
      @descriptions[method_name.to_s]
    end

    def grpc(method_name)
      @grpc[method_name.to_s]
    end
  end
end
