# frozen_string_literal: true

require 'fileutils'
require 'rainbow'

module LNDClientInternal
  module GrpcGeneratorController
    REQUIRE_REGEX = /^require\s+['"].*_pb['"]/

    def self.upgrade!
      cleanup!

      download!

      Dir['temp/grpc-upgrade/lnd/lnrpc/**/*.proto'].each do |proto_file|
        next if proto_file =~ /googleapis/

        run!(generate_command(proto_file.sub('temp/grpc-upgrade/lnd/lnrpc/', '')), print_output: true)
      end

      fix_requires!

      remove_references!

      puts "\nDone!"
    end

    def self.remove_references!
      run!('rm -rf temp/grpc-upgrade', print_output: false)
    end

    def self.cleanup!
      run!('rm -rf components/grpc', print_output: false)
      run!('rm -rf temp/grpc-upgrade', print_output: false)

      FileUtils.mkdir_p('components/grpc')
      FileUtils.mkdir_p('temp/grpc-upgrade')
    end

    def self.download!
      run!('git clone https://github.com/lightningnetwork/lnd.git temp/grpc-upgrade/lnd', print_output: false)
      run!('git clone https://github.com/googleapis/googleapis.git temp/grpc-upgrade/lnd/lnrpc/googleapis',
           print_output: false)
    end

    def self.generate_command(proto_file)
      [
        'cd temp/grpc-upgrade/lnd/lnrpc/; grpc_tools_ruby_protoc',
        '--proto_path googleapis:.',
        '--ruby_out=../../../../components/grpc/',
        '--grpc_out=../../../../components/grpc/',
        proto_file
      ].join(' ')
    end

    def self.fix_requires!
      5.times do
        Dir['components/grpc/**/*.rb'].each do |file|
          content = File.read(file)
          next unless content =~ REQUIRE_REGEX

          apply!(file, content)
        end
      end
    end

    def self.apply!(file, content)
      content.gsub!(REQUIRE_REGEX) do |require_statement|
        required_file = require_statement.match(/['"](.*)['"]/)[1]

        relative_path = relative_path_to(file, required_file)

        require_relative_statement = "require_relative '#{relative_path}'"

        puts "\n#{Rainbow('>').yellow} #{file}"
        puts "  #{Rainbow(require_statement).red} -> #{Rainbow(require_relative_statement).green}"

        require_relative_statement
      end

      File.write(file, content)
    end

    def self.run!(command, print_output: false)
      puts "\n#{Rainbow('>').yellow} #{command}"
      output = `#{command}`
      puts output if print_output
    end

    def self.relative_path_to(file, required_file)
      current_dir = File.dirname(file)

      full_required_path = Dir.glob("**/#{required_file}.rb").first
      relative_path = Pathname.new(full_required_path).relative_path_from(Pathname.new(current_dir)).to_s

      relative_path.sub(/\.rb$/, '').sub(%r{^\./}, '')
    end
  end
end
