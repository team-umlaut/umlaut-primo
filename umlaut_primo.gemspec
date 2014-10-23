$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "umlaut_primo/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "umlaut-primo"
  s.version     = UmlautPrimo::VERSION
  s.authors     = ["Scot Dalton"]
  s.email       = ["scotdalton@gmail.com"]
  s.homepage    = "https://github.com/team-umlaut/umlaut-primo"
  s.summary     = "Umlaut service to provide fulltext, holdings, etc. from the Primo discovery solution."
  s.description = "Umlaut service to provide fulltext, holdings, etc. from the Primo discovery solution."

  s.files = Dir["{lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "require_all", ">= 1.2.1"
  # s.add_dependency "umlaut", "~> 3.1.0"
  s.add_dependency "exlibris-primo", ">= 1.0.8"

  # Dummy app dependencies
  s.add_development_dependency "rake", "~> 10.3.0"
  s.add_development_dependency "jquery-rails", "~> 3.1.0"
  s.add_development_dependency "mysql2", "~> 0.3.11"
  s.add_development_dependency "vcr", "~> 2.9.0"
  s.add_development_dependency "webmock", "~> 1.20.0"
  s.add_development_dependency "pry", "~> 0.10.0"
end
