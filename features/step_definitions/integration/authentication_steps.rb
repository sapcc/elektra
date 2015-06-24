Given(/^I am not logged in$/) do
  puts "::::::::::::::::::::::::::: NOT LOGGED IN(BEVOR)"
  puts "env: #{ENV['CAPYBARA_APP_HOST']}"
  puts "page.current_url: #{page.current_url}"
  puts "monsoon_openstack_auth.logout_path: #{monsoon_openstack_auth.logout_path}"
  puts "root_path: #{root_path}"
  puts "root_url: #{root_url}"
  visit root_path
  puts "page.current_url: #{page.current_url}"
  puts "logout_url: #{monsoon_openstack_auth.logout_path}"
  visit monsoon_openstack_auth.logout_path
  puts "::::::::::::::::::::::::::: NOT LOGGED IN(AFTER)"
  puts  "page.current_url: #{page.current_url}"
end

When(/^I visit "(.*?)"$/) do |path|
  puts "::::::::::::::::::::::::::: VISIT INSTANCES (BEVOR)"
  puts  page.current_url
  visit path
  puts "::::::::::::::::::::::::::: VISIT INSTANCES (AFTER)"
  puts  page.current_url
end

Then(/^I am redirected to login page$/) do
  puts "::::::::::::::::::::::::::: SHOULD BE REDIRECTED"
  puts  page.current_url
  puts ">>>>>>>>>>>>>>>>>>>>>>>HTML"
  puts page.html
  expect(current_path).to eq(monsoon_openstack_auth.new_session_path)
end

Then(/^I see login form$/) do
  expect(page).to have_selector("form[action='#{monsoon_openstack_auth.sessions_path}']")
end

Then(/^It works$/) do
end

def current_path
  URI.parse(current_url).path
end
