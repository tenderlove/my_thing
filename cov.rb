require 'coverage'
require 'json'
require 'rspec'

LOG = File.open('run_log.txt', 'w')
Coverage.start

RSpec.configuration.after(:suite) { LOG.close }

RSpec.configuration.around(:example) do |example|
  before = Coverage.peek_result
  example.call
  after = Coverage.peek_result
  LOG.puts JSON.dump [ example.full_description, before, after ]
end
