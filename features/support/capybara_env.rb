# phantomjs is required by poltergeist
require 'phantomjs'

# Poltergeist is a headless web driver for capybara  
# Register slightly larger than default window size...

p Phantomjs.path
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, { 
    phantomjs: Phantomjs.path,
    debug: false, # change this to true to troubleshoot
    phantomjs_options: ['--ssl-protocol=any', '--ignore-ssl-errors=true']
  })
end

# register poltergeist for capybara screenshots
Capybara::Screenshot.register_driver :poltergeist do |driver, path|
  if driver.respond_to?(:save_screenshot)
    driver.save_screenshot(path)
  else
    driver.render(path)
  end
end

def find_available_port
  server = TCPServer.new('127.0.0.1', 0)
  server.addr[1]
ensure
  server.close if server
end

Capybara.javascript_driver = :poltergeist
#Capybara.default_driver    = :poltergeist 
Capybara.server_port       = find_available_port # Needed for runnning multiple features simultaniously
Capybara.app_host          = ENV['CAPYBARA_APP_HOST'] #ENV['CAPYBARA_APP_HOST'].nil? ? "http://localhost:#{Capybara.server_port}" : ENV['CAPYBARA_APP_HOST']
Capybara.run_server        = ENV['CAPYBARA_APP_HOST'].nil?
Capybara.default_wait_time = 5
