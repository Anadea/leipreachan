require 'simplecov'
require 'simplecov-json'
require 'simplecov-rcov'

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter,
  SimpleCov::Formatter::RcovFormatter
]

SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'leipreachan'
Dir["spec/support/**/*.rb"].each { |f| load f }

module Rails; end unless defined?(Rails)

RSpec.configure do |config|
  config.include LeipreachanHelper
  config.before :each do
    allow_message_expectations_on_nil
    Rails.stub(:root).and_return('/tmp/Rails')
    Rails.stub(:env).and_return('test')
    # ActiveRecord::Base.stub(:configurations).and_return({'test' => {}})
    %w(adapter username user password host database).each do |k, v|
      ActiveRecord::Base.configurations['test'].stub(:[]).with(k).and_return(nil)
    end
  end
end

