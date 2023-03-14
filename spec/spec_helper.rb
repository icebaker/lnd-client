# frozen_string_literal: true

require 'rainbow'

require 'dotenv/load'

require_relative './helpers/vcr'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before(:suite) do
    VCR::Monitor.instance.reboot!
  end

  config.after(:suite) do
    if ARGV.count == 0 && RSpec.world.filtered_examples.values.flatten.none?(&:exception)
      accessed_files = VCR::Monitor.instance.accessed_files

      unused_files = []

      Dir.glob('spec/data/**/*').each do |file|
        next unless File.file?(file)
        next if accessed_files[file]

        unused_files << file
      end

      unless unused_files.empty?
        print Rainbow("\n\nWarning: #{unused_files.size} unused test data files were found.").magenta

        if $stdout.tty? && !unused_files.empty? &&
           ENV.fetch('LND_CLIENT_DELETE_UNUSED_TEST_DATA', 'false') == 'true'

          puts "\nDeleting unused files..."
          unused_files.each do |path|
            File.delete(path)
            puts " - #{Rainbow(path).red}"
          end

          print "\n#{unused_files.size} unused test data files deleted!"
        else
          unused_files.each do |path|
            puts " - #{Rainbow(path).yellow}"
          end
        end
      end
    end
  end
end
