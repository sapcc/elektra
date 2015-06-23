Given(/^I am not logged in$/) do
  visit monsoon_openstack_auth.logout_path
end

When(/^I visit "(.*?)"$/) do |path|
  visit path
end

Then(/^I am redirected to login page$/) do
  puts ":::::::::::::::::::::::::::"
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
