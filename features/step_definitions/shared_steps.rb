#
# Actions
#
And(/^I log in as test_user/) do
  fill_in "username", :with => "#{ENV['CCTEST_USER']}"
  fill_in "password", :with => "#{ENV['CCTEST_PASSWORD']}"
  click_on 'Sign in'
  expect(page.driver.status_code.should).to eq(200)
end

Given(/^I am not logged in$/) do
  visit monsoon_openstack_auth.logout_path
end

Given /^Test user has accepted terms of use$/ do
  DashboardController.any_instance.stub(:tou_accepted?).and_return(true)
end

Given /^Test user has not accepted terms of use$/ do
  DashboardController.any_instance.stub(:tou_accepted?).and_return(false)
end

#
# Elements
#
When /^I click on "(.*?)"$/ do |button|
  click_on(button)
end

Then(/^I see a "(.*?)" (button|link)$/) do |button_text,l|
  expect(page).to have_selector('a', text: button_text)
end

Then(/^I don't see a "(.*?)" (button|link)$/) do |button_text,l|
  expect(page).not_to have_selector('a', text: button_text)
end

#
# Paths steps
#
Then(/^the page status code is successful$/) do
  expect(page.status_code).to be(200)
end

Given(/I am on the root page$/) do
  visit root_path
end

When(/^I visit domain$/) do
  visit "/" + ENV['CCTEST_DOMAIN']
end

When(/^I visit domain path "(.*?)"$/) do |path|
  @cclast_domain_path =  "/" + ENV['CCTEST_DOMAIN'] + "/" + path
  visit @cclast_domain_path
end

When(/^I visit project path "(.*?)"$/) do |path|
  @cclast_project_path =  "/" + ENV['CCTEST_DOMAIN'] + "/" + ENV['CCTEST_PROJECT'] + "/" + path
  visit @cclast_project_path
end

Then(/^I am redirected to domain path "(.*?)"$/) do |path|
  expect(current_path).to eq("/" + ENV['CCTEST_DOMAIN'] + "/" + path)
end

Then(/^I am redirected to project path "(.*?)"$/) do |path|
  expect(current_path).to eq( "/" + ENV['CCTEST_DOMAIN'] + "/" + ENV['CCTEST_PROJECT'] + "/" + path)
end