# frozen_string_literal: true

require 'securerandom'

require_relative '../logic/string'
require_relative '../components/grpc'

module LNDClientInternal
  class DocumentationController
    PROGRESS = true
    PATH = 'docs/README.md'
    KEY = '<!-- [INJECT:GRP:DOCS] -->'

    attr_reader :available_methods

    def self.format(code)
      id = SecureRandom.hex(32)
      path = "temp/#{id}.rb"
      File.write("temp/#{id}.rb", code.gsub(', ', ",\n"))
      `rubocop -A -c docs/.rubocop.yml #{path}`
      output = File.read("temp/#{id}.rb")
      File.delete("temp/#{id}.rb")
      output.strip
    end

    def self.generate!
      services = LNDClientInternal::GRPC::SERVICES.keys.map(&:to_sym)

      if PROGRESS
        total = services.sum do |service|
          new(
            LNDClientInternal::GRPC::SERVICES[service].const_get(:Service)
          ).available_methods.size * 2
        end
        progressbar = ProgressBar.create(total: total, format: '%a %e |%b>>%i| %P% | %c of %C')
      end

      content = ''

      services.each do |service|
        content += "## #{service}\n"
        doc = new(LNDClientInternal::GRPC::SERVICES[service].const_get(:Service))

        doc.available_methods.each do |method_name|
          content += "\n### #{method_name}\n"

          url = "https://lightning.engineering/api-docs/api/lnd/#{service}/#{method_name.gsub('_', '-')}/index.html"

          content += "\n[lightning.engineering/#{service}/#{method_name.gsub('_', '-')}](#{url})\n"

          description = doc.describe(method_name)
          content += "\n```ruby\n"

          code = "client.#{service}.#{method_name}"

          code += "(\n#{description[:input].inspect}\n)" if !description[:input].nil? && !description[:input].empty?

          code += " do |data|\n  puts data.inspect # => { ... }\nend" if method_name =~ /^subscribe/

          content += if !description[:input].nil? && !description[:input].empty?
                       "#{self.format(code)}\n```\n"
                     else
                       "#{code}\n```\n"
                     end

          progressbar.increment if PROGRESS

          if !description[:output].nil? && !description[:output].empty?
            code = self.format(description[:output].inspect)
            content += "\nOutput:\n```ruby\n#{code}\n```\n"
          end

          progressbar.increment if PROGRESS
        end
      end

      document = File.read(PATH)

      parts = document.split(KEY)

      File.write(PATH, "#{parts[0]}#{KEY}\n\n#{content}\n#{KEY}#{parts[2]}")

      progressbar.finish

      puts "\nDocumentation updated: #{PATH}\n"
    end

    def initialize(grpc_service)
      @grpc_service = grpc_service
      @descriptions = {}
      @grpc = {}

      build!
    end

    def build!
      @available_methods = @grpc_service.rpc_descs.values.map do |desc|
        method_name = LNDClientInternal::StringLogic.underscore(desc.name.to_s)

        build_description!(method_name, desc)

        @grpc[method_name] = desc

        method_name
      end.sort
    end

    def build_description!(method_name, desc)
      input = desc.input.new.to_h if desc.input.respond_to?(:new)
      output = desc.output.new.to_h if desc.output.respond_to?(:new)

      @descriptions[method_name] = { method: method_name }

      @descriptions[method_name][:input] = input if input
      @descriptions[method_name][:output] = output if output
    end

    def describe(method_name)
      @descriptions[method_name.to_s]
    end

    def grpc(method_name)
      @grpc[method_name.to_s]
    end
  end
end
