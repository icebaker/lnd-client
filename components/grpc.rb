# frozen_string_literal: true

require_relative './grpc/lightning_services_pb'

module GRPC
  SERVICES = {
    lightning: Lnrpc::Lightning
  }.freeze
end
