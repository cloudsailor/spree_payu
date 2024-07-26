# encoding: UTF-8
require_relative 'lib/spree_payu/version.rb'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_payu'
  s.version     = SpreePayuGateway.version
  s.summary     = 'PayU payment gateway for Spree'
  s.description = 'PayU payment gateway for Spree'
  s.required_ruby_version = '>= 3.0'
  s.license     = 'BSD-3-Clause'

  s.metadata = {
    "bug_tracker_uri"   => "https://github.com/cloudsailor/spree_payu/issues",
    "changelog_uri"     => "https://github.com/cloudsailor/spree_payu/releases/tag/v#{s.version}",
    "source_code_uri"   => "https://github.com/cloudsailor/spree_payu/tree/v#{s.version}",
  }

  s.authors           = ['Cloud Sailor AS', 'Cloud Sailor Sp. z o.o.']
  s.email             = 'support@cloudsailor.com'
  s.homepage          = 'https://github.com/cloudsailor/spree_payu'

  s.files        = Dir['CHANGELOG', 'README.md', 'LICENSE', 'lib/**/*', 'app/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency('deface')
  s.add_dependency('faraday')
  s.add_dependency('openssl')

  spree_version = '>= 4.6.0', '< 5.0'
  s.add_dependency 'spree_backend', spree_version
  s.add_dependency 'spree_core', spree_version
  s.add_dependency 'spree_auth_devise'
  s.add_dependency  'bigdecimal'
end
