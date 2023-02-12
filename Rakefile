# frozen_string_literal: true

require_relative './controllers/documentation'
require_relative './controllers/grpc_generator'

namespace :grpc do
  desc 'Generate gRPC Documentation'
  task :docs do
    require 'ruby-progressbar'
    LNDClientInternal::DocumentationController.generate!
  end

  desc 'Upgrade lnd Protocol Buffers for gGRPC'
  task :upgrade do
    LNDClientInternal::GrpcGeneratorController.upgrade!
  end
end
