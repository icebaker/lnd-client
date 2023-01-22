# frozen_string_literal: true

require_relative './controllers/grpc_generator'

namespace :grpc do
  desc 'Upgrade lnd Protocol Buffers for gGRPC'
  task :upgrade do
    GrpcGeneratorController.upgrade!
  end
end
