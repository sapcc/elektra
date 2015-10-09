Given(/User is logged in/) do
  visit '/monsooncc_test/start'
  fill_in "username", :with => "test_admin"
  fill_in "password", :with => "secret"
  click_on 'Sign in'
  expect(page.driver.status_code.should).to eq(200)
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