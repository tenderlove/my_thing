require 'minitest/autorun'
require 'cov_mt' if ENV['COLLECTION']
require 'my_thing'

describe Whatever do
  before :each do
    @thing = Whatever.new
  end

  it 'bars' do
    @thing.bar
  end

  it 'bars again' do
    @thing.bar
  end

  it 'baz' do
    @thing.baz
  end
end

