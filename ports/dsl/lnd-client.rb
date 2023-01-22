# frozen_string_literal: true

require_relative '../../controllers/client'
require_relative '../../static/spec'

module LNDClient
  def self.new(params)
    ClientController.new(params)
  end

  def self.version
    Static::SPEC[:version]
  end
end
