require File.expand_path('../boot', __FILE__)

# require 'rails/all'
require "action_controller/railtie"
require "action_mailer/railtie"
# require "active_resource/railtie"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Cenit
  class Application < Rails::Application
    config.force_ssl = true if ENV['SSL'].to_b 
    config.autoload_paths += %W(#{config.root}/lib)
    config.assets.prefix = "/portal/assets"
   end
end
