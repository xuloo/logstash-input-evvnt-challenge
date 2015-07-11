Gem::Specification.new do |s|
  s.name = 'logstash-input-evvnt'
  s.version         = '0.0.1'
  s.licenses = ['Apache License (2.0)']
  s.summary = "This example input streams event data from the evvnt challenge url at regular intervals (default 60s)."
  s.description = "This gem is a logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/plugin install gemname. This gem is not a stand-alone program"
  s.authors = ["Xuloo"]
  s.email = 'trevor@xuloo.cc'
  s.homepage = "http://www.elastic.co/guide/en/logstash/current/index.html"
  s.require_paths = ["lib"]

  # Files
  s.files = `git ls-files`.split($\)
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "input" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core", '>= 1.4.0', '< 2.0.0'
  s.add_runtime_dependency 'logstash-codec-plain'
  s.add_runtime_dependency 'faraday_middleware'
  s.add_development_dependency 'logstash-devutils'
end
