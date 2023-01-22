# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: neutrinorpc/neutrino.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("neutrinorpc/neutrino.proto", :syntax => :proto3) do
    add_message "neutrinorpc.StatusRequest" do
    end
    add_message "neutrinorpc.StatusResponse" do
      optional :active, :bool, 1
      optional :synced, :bool, 2
      optional :block_height, :int32, 3
      optional :block_hash, :string, 4
      repeated :peers, :string, 5
    end
    add_message "neutrinorpc.AddPeerRequest" do
      optional :peer_addrs, :string, 1
    end
    add_message "neutrinorpc.AddPeerResponse" do
    end
    add_message "neutrinorpc.DisconnectPeerRequest" do
      optional :peer_addrs, :string, 1
    end
    add_message "neutrinorpc.DisconnectPeerResponse" do
    end
    add_message "neutrinorpc.IsBannedRequest" do
      optional :peer_addrs, :string, 1
    end
    add_message "neutrinorpc.IsBannedResponse" do
      optional :banned, :bool, 1
    end
    add_message "neutrinorpc.GetBlockHeaderRequest" do
      optional :hash, :string, 1
    end
    add_message "neutrinorpc.GetBlockHeaderResponse" do
      optional :hash, :string, 1
      optional :confirmations, :int64, 2
      optional :stripped_size, :int64, 3
      optional :size, :int64, 4
      optional :weight, :int64, 5
      optional :height, :int32, 6
      optional :version, :int32, 7
      optional :version_hex, :string, 8
      optional :merkleroot, :string, 9
      optional :time, :int64, 10
      optional :nonce, :uint32, 11
      optional :bits, :string, 12
      optional :ntx, :int32, 13
      optional :previous_block_hash, :string, 14
      optional :raw_hex, :bytes, 15
    end
    add_message "neutrinorpc.GetBlockRequest" do
      optional :hash, :string, 1
    end
    add_message "neutrinorpc.GetBlockResponse" do
      optional :hash, :string, 1
      optional :confirmations, :int64, 2
      optional :stripped_size, :int64, 3
      optional :size, :int64, 4
      optional :weight, :int64, 5
      optional :height, :int32, 6
      optional :version, :int32, 7
      optional :version_hex, :string, 8
      optional :merkleroot, :string, 9
      repeated :tx, :string, 10
      optional :time, :int64, 11
      optional :nonce, :uint32, 12
      optional :bits, :string, 13
      optional :ntx, :int32, 14
      optional :previous_block_hash, :string, 15
      optional :raw_hex, :bytes, 16
    end
    add_message "neutrinorpc.GetCFilterRequest" do
      optional :hash, :string, 1
    end
    add_message "neutrinorpc.GetCFilterResponse" do
      optional :filter, :bytes, 1
    end
    add_message "neutrinorpc.GetBlockHashRequest" do
      optional :height, :int32, 1
    end
    add_message "neutrinorpc.GetBlockHashResponse" do
      optional :hash, :string, 1
    end
  end
end

module Neutrinorpc
  StatusRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("neutrinorpc.StatusRequest").msgclass
  StatusResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("neutrinorpc.StatusResponse").msgclass
  AddPeerRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("neutrinorpc.AddPeerRequest").msgclass
  AddPeerResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("neutrinorpc.AddPeerResponse").msgclass
  DisconnectPeerRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("neutrinorpc.DisconnectPeerRequest").msgclass
  DisconnectPeerResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("neutrinorpc.DisconnectPeerResponse").msgclass
  IsBannedRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("neutrinorpc.IsBannedRequest").msgclass
  IsBannedResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("neutrinorpc.IsBannedResponse").msgclass
  GetBlockHeaderRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("neutrinorpc.GetBlockHeaderRequest").msgclass
  GetBlockHeaderResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("neutrinorpc.GetBlockHeaderResponse").msgclass
  GetBlockRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("neutrinorpc.GetBlockRequest").msgclass
  GetBlockResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("neutrinorpc.GetBlockResponse").msgclass
  GetCFilterRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("neutrinorpc.GetCFilterRequest").msgclass
  GetCFilterResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("neutrinorpc.GetCFilterResponse").msgclass
  GetBlockHashRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("neutrinorpc.GetBlockHashRequest").msgclass
  GetBlockHashResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("neutrinorpc.GetBlockHashResponse").msgclass
end