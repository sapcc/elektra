#
# Actions
#
And(/^I log in as test_user/) do
  fill_in "username", :with => "#{ENV['CCTEST_USER']}"
  fill_in "password", :with => "#{ENV['CCTEST_PASSWORD']}"
  click_on 'Sign in'
  expect(page.driver.status_code).to eq(200)
end

Given(/^I am not logged in$/) do
  visit "#{ENV['CCTEST_DOMAIN']}/auth/logout"
end

Given /^Test user has accepted terms of use$/ do
  # the below code doesn't seem to work. defined? DashboardController is always false
  # if defined? DashboardController
  #   allow_any_instance_of(DashboardController).to receive(:check_terms_of_use).and_return(true)
  #   allow_any_instance_of(DashboardController).to receive(:tou_accepted?).and_return(Settings.actual_terms.version)
  # end
  # check if the accept terms of use checkbox is present on the page. If yes, click it and accept the tou
  # This feels like a not very stable workaround but I couldn't find a way to just mock that the user has accepted the tou :(
  # it also really only works if this step is performed after an earlier step tried to access any page
  if page.has_css?('#accept_tos')
    check('terms_of_use')
    click_on 'Accept'
  end
end

Given /^Test user has not accepted terms of use$/ do
  if defined? DashboardController
    allow_any_instance_of(DashboardController).to receive(:check_terms_of_use).and_return(false)
  end
end

#
# Elements
#
When /^I click on "(.*?)"$/ do |button|
  find(:link, button).trigger('click')
  # click_on(button)
end

When /^I choose "(.*?)" radiobutton$/ do |radio|
  choose(radio)
end

Then /^I see active panel "(.*?)"$/ do |panel_id|
  page.should have_css("##{panel_id}.active")
end

Then(/^I see a "(.*?)" (button|link)$/) do |button_text,l|
  #expect(page).to have_selector('a', text: button_text)
  expect(find(:link, button_text)).not_to be(nil)
end

Then(/^I see a selectbox with id "(.*?)"$/) do |id|
  expect(page).to have_select(id)
end

Then(/^I see the domain home page$/) do
  expect(page).to have_selector('a', text: 'Home')
end

And(/^options of "(.*?)" contains names and ids$/) do |id|
  option = find_field(id).all('option').last
  expect(option.value).not_to eq("undefined")
  expect(option.text).not_to eq("undefined")
end

Then(/^I select the first option of "([^"]*)"$/) do |selectbox|
  options = find(:select, selectbox, {}).all('option').collect(&:text)
  if options.length > 2
      option = options.find { |item| item != "" }
      find(:select, selectbox, {}).find(:option, option, {}).select_option
  end
end

When(/^I select "([^"]*)" from "([^"]*)"$/) do |option, selectbox|
  find(:select, selectbox, {}).find(:option, option, {}).select_option
end

Then(/^I see select "([^"]*)"$/) do |selectbox|
  expect(page).to have_select(selectbox)
end

When(/^I wait for (\d+) seconds?$/) do |n|
  sleep(n.to_i)
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
  visit "/"
end

When(/^I visit the test domain$/) do
  visit "/" + ENV['CCTEST_DOMAIN']
end

When(/^I visit path "(.*?)"$/) do |path|
  visit path
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

Then(/^I see the project home page or project wizard$/) do
  project_home =  "/" + ENV['CCTEST_DOMAIN'] + "/" + ENV['CCTEST_PROJECT'] + "/home"
  wizard_page =  "/" + ENV['CCTEST_DOMAIN'] + "/" + ENV['CCTEST_PROJECT'] + "/identity/project/wizard"

  expect(current_path == project_home || current_path == wizard_page).to eq(true)
end

Then(/^I see warning "(.*?)"$/) do |warning|
  expect(page).to have_content warning
end

Then(/^I don't see "(.+)?"$/) do |text|
  wait_for_ajax
  expect(page).not_to have_content(text)
end

Then(/^All AJAX calls are successful$/) do
  wait_for_ajax
  expect(all_ajax_calls_successful?).to eq(true)
end
