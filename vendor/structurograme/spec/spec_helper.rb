require 'spec'
require File.expand_path(File.dirname(__FILE__) + '/../lib/structurograme.rb')

Spec::Runner.configure do |config|
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  # 
  # For more information take a look at Spec::Example::Configuration and Spec::Runner
end

FONT = File.expand_path(File.dirname(__FILE__) + '/../extras/cour.ttf')