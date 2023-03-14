# frozen_string_literal: true

require_relative 'static/spec'

Gem::Specification.new do |spec|
  spec.name    = LNDClientInternal::Static::SPEC[:name]
  spec.version = LNDClientInternal::Static::SPEC[:version]
  spec.authors = [LNDClientInternal::Static::SPEC[:author]]

  spec.summary = LNDClientInternal::Static::SPEC[:summary]
  spec.description = LNDClientInternal::Static::SPEC[:description]

  spec.homepage = LNDClientInternal::Static::SPEC[:documentation]

  spec.license = LNDClientInternal::Static::SPEC[:license]

  spec.required_ruby_version = Gem::Requirement.new('>= 3.0.0')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = LNDClientInternal::Static::SPEC[:github]
  spec.metadata['documentation_uri'] = LNDClientInternal::Static::SPEC[:documentation]
  spec.metadata['bug_tracker_uri'] = LNDClientInternal::Static::SPEC[:issues]

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{\A(?:test|spec|docs|features)/})
    end
  end

  spec.require_paths = ['ports/dsl']

  spec.add_dependency 'grpc', '~> 1.52'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
