# frozen_string_literal: true

require_relative 'lib/grape-swagger/representable/version'

Gem::Specification.new do |s|
  s.name          = 'grape-swagger-representable'
  s.version       = GrapeSwagger::Representable::VERSION
  s.authors       = ['Kirill Zaitsev']
  s.email         = ['kirik910@gmail.com']

  s.summary       = 'Grape swagger adapter to support representable object parsing'
  s.license       = 'MIT'

  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.bindir        = 'exe'
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  github_uri = "https://github.com/ruby-grape/#{s.name}"

  s.homepage = github_uri

  s.metadata = {
    'rubygems_mfa_required' => 'true',
    'bug_tracker_uri' => "#{github_uri}/issues",
    'documentation_uri' => "https://www.rubydoc.info/gems/#{s.name}/#{s.version}",
    'homepage_uri' => s.homepage,
    'source_code_uri' => github_uri
  }

  s.required_ruby_version = '>= 3.1'

  s.add_dependency 'grape-swagger', '~> 2.0'
  s.add_dependency 'representable', '~> 3.2'
end
