# frozen_string_literal: true

require_relative '../../controllers/connection'
require_relative '../../controllers/client'
require_relative '../../controllers/multiclient'
require_relative '../../static/spec'

module LNDClient
  def self.new(...)
    LNDClientInternal::ClientController.new(
      LNDClientInternal::Connection.standalone(...)
    )
  end

  def self.add_connection!(...)
    LNDClientInternal::Multiclient.instance.add_connection!(...)
  end

  def self.connections(...)
    LNDClientInternal::Multiclient.instance.connections(...)
  end

  def self.as(...)
    LNDClientInternal::Multiclient.instance.as(...)
  end

  def self.remove_connection!(...)
    LNDClientInternal::Multiclient.instance.remove_connection!(...)
  end

  def self.version
    LNDClientInternal::Static::SPEC[:version]
  end
end
