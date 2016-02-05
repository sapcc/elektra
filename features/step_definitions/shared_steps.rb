And(/^Login as test_user/) do
  fill_in "username", :with => "dashboard_test_user"
  fill_in "password", :with => "dashboard_test_user"
  click_on 'Sign in'
  expect(page.driver.status_code.should).to eq(200)
end

Then(/^the page status code is successful$/) do
  expect(page.status_code).to be(200)
end

Given(/I am on the root page$/) do
  visit root_path
end

Given(/^I am not logged in$/) do
  visit monsoon_openstack_auth.logout_path
end

When(/^I visit "(.*?)"$/) do |path|
  visit path
end

When /^I click on "(.*?)"$/ do |button| 
  click_on(button)
end

Then(/^I am redirected to "(.*?)"$/) do |path|
  expect(current_path).to eq(path)
end

Then(/^I see a "(.*?)" button$/) do |button_text|
  expect(page).to have_selector('a', text: button_text)  
end