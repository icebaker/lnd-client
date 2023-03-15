# frozen_string_literal: true

require 'singleton'

require_relative 'connection'

require_relative 'client'

module LNDClientInternal
  class Multiclient
    include Singleton

    def initialize
      @clients = {}
    end

    def add_connection!(id, *params)
      @clients[id] = ClientController.new(Connection.standalone(*params))
    end

    def remove_connection!(id)
      @clients.delete(id)
    end

    def as(id)
      @clients[id]
    end

    def clear!
      @clients = {}
    end

    def connections
      @clients.keys
    end
  end
end
