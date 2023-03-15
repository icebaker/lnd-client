# frozen_string_literal: true

module LNDClient
  module Errors
    class LNDClientError < StandardError; end

    class TooManyArgumentsError < LNDClientError; end
    class ArgumentError < LNDClientError; end
  end
end
