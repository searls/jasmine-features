require 'ruby-debug'
require 'capybara/cucumber'

Capybara.default_driver = :selenium
Capybara.app_host = "http://localhost:4567"