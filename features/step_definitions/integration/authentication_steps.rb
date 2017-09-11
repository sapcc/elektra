When(/^I fill in "(.*?)" as "(.*?)"/) do |value,field|
  fill_in field, :with => value
end

Then(/^I am redirected to login page$/) do
  expect(current_path.match(/\/.+\/auth\/login/)).not_to be(nil)
end

Then(/^I see login form$/) do
  expect(page).to have_selector("form[action*='/auth/sessions']")
end

And(/^I click on user navigation$/) do
  first('a.navbar-identity').click
end

Then(/^It works$/) do
end

############# Multi domains #####################
Given(/^I am not logged in in domain(\d+)$/) do |number|
  visit "#{domain(number)}/auth/logout"
end

When(/^I visit domain(\d+) home page$/) do |number|
  visit "/#{domain(number)}/home"
end

Then(/^I am redirected to domain(\d+) login page$/) do |number|
  expect(current_path.match(/\/.+\/auth\/login/)).not_to be(nil)
end

def current_path
  URI.parse(current_url).path
end

def domain(number)
  case number.to_i
  when 1 then ENV['CCTEST_DOMAIN']
  when 2 then ENV['CCTEST2_DOMAIN']
  end
end
