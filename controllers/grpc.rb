module GrpcController
  def self.upgrade!
    # mkdir grpc-upgrade
    # cd grpc-upgrade

    # git clone https://github.com/googleapis/googleapis.git
    # curl -o lightning.proto -s https://raw.githubusercontent.com/lightningnetwork/lnd/master/lnrpc/lightning.proto

    # grpc_tools_ruby_protoc --proto_path googleapis:. --ruby_out=. --grpc_out=. lightning.proto

    puts 'TODO'
  end
end
