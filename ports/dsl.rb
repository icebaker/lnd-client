# frozen_string_literal: true

require_relative '../static/spec'

module LNDClient
  def version
    Static::Spec[:version]
  end
end
