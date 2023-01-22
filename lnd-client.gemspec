# frozen_string_literal: true

require_relative 'static/spec'

Gem::Specification.new do |spec|
  spec.name    = Static::Spec[:name]
  spec.version = Static::Spec[:version]
  spec.authors = [Static::Spec[:author]]

  spec.summary = Static::Spec[:summary]
  spec.description = Static::Spec[:description]

  spec.homepage = Static::Spec[:github]

  spec.license = Static::Spec[:license]

  spec.required_ruby_version = Gem::Requirement.new('>= 3.2.0')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = Static::Spec[:github]

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{\A(?:test|spec|features)/})
    end
  end

  spec.require_paths = ['ports/dsl']

  spec.add_dependency 'grpc', '~> 1.50'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
