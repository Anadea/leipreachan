$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'leipreachan'

module Rails; end unless defined?(Rails)

RSpec.configure do |config|
  config.before :each do
    Rails.stub(:root).and_return('/tmp/Rails')
    Rails.stub(:env).and_return('test')
  end
end

