require 'coverage'
require 'json'
require 'rspec'

LOGS = []
Coverage.start

RSpec.configuration.after(:suite) {
  File.open('run_log.json', 'w') { |f| f.write JSON.dump LOGS }
}

RSpec.configuration.around(:example) do |example|
  before = Coverage.peek_result
  example.call
  after = Coverage.peek_result
  LOGS << [ example.full_description, before, after ]
end
