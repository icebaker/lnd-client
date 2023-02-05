# frozen_string_literal: true

require_relative '../../controllers/client'
require_relative '../../static/spec'

module LNDClient
  def self.new(params)
    LNDClientInternal::ClientController.new(params)
  end

  def self.version
    LNDClientInternal::Static::SPEC[:version]
  end
end
