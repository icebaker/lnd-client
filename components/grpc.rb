# frozen_string_literal: true

require_relative './grpc/lightning_services_pb'
require_relative './grpc/routerrpc/router_services_pb'

module GRPC
  SERVICES = {
    lightning: Lnrpc::Lightning,
    router: Routerrpc::Router
  }.freeze
end
