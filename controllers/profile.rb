# frozen_string_literal: true

require 'singleton'

require_relative '../components/connector'
require_relative 'client'

module LNDClientInternal
  class Profile
    include Singleton

    def initialize
      @clients = {}
    end

    def register(id, credentials)
      Connector.instance.register(id, credentials)

      @clients[id] = ClientController.new(
        Connector.instance.for(id)
      )
    end

    def as(id)
      @clients[id]
    end
  end
end
