# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.2'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  config.frameworks -= [:active_record]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug
  
  config.action_controller.session = {
    :session_key => "_struct_gen_session",
    :secret => "omgwtflol mano structgenas padare gyvenima lengvu!"
  }

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  #config.action_controller.session_store = :file_store
  
  # See Rails::Configuration for more options
  config.gem "libxml-ruby", :lib => "xml/libxml", :version => ">= 0.9.5"
  config.gem "rmagick", :lib => 'RMagick'
  config.gem "rspec-rails", :lib => 'spec/rails'
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Include your application configuration below
require 'custom_enviroment.rb'
