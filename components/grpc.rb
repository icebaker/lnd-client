# frozen_string_literal: true

require_relative './grpc/autopilotrpc/autopilot_services_pb'
require_relative './grpc/chainrpc/chainkit_services_pb'
require_relative './grpc/chainrpc/chainnotifier_services_pb'
require_relative './grpc/devrpc/dev_services_pb'
require_relative './grpc/invoicesrpc/invoices_services_pb'
require_relative './grpc/lightning_services_pb'
require_relative './grpc/neutrinorpc/neutrino_services_pb'
require_relative './grpc/peersrpc/peers_services_pb'
require_relative './grpc/routerrpc/router_services_pb'
require_relative './grpc/signrpc/signer_services_pb'
require_relative './grpc/stateservice_services_pb'
require_relative './grpc/verrpc/verrpc_services_pb'
require_relative './grpc/walletrpc/walletkit_services_pb'
require_relative './grpc/walletunlocker_services_pb'
require_relative './grpc/watchtowerrpc/watchtower_services_pb'
require_relative './grpc/wtclientrpc/wtclient_services_pb'

module LNDClientInternal
  module GRPC
    SERVICES = {
      autopilot: Autopilotrpc::Autopilot,
      chain_kit: Chainrpc::ChainKit,
      chain_notifier: Chainrpc::ChainNotifier,
      dev: Devrpc::Dev,
      invoices: Invoicesrpc::Invoices,
      lightning: Lnrpc::Lightning,
      neutrino_kit: Neutrinorpc::NeutrinoKit,
      peers: Peersrpc::Peers,
      router: Routerrpc::Router,
      signer: Signrpc::Signer,
      state: Lnrpc::State,
      versioner: Verrpc::Versioner,
      wallet_kit: Walletrpc::WalletKit,
      wallet_unlocker: Lnrpc::WalletUnlocker,
      watchtower: Watchtowerrpc::Watchtower,
      watchtower_client: Wtclientrpc::WatchtowerClient
    }.freeze
  end
end
