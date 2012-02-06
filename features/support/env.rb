require 'capybara/cucumber'
require 'capybara/webkit'

Capybara.default_driver = :webkit
Capybara.app_host = "http://localhost:9394"