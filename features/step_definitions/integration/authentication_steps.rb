When(/^I fill in "(.*?)" as "(.*?)"/) do |value,field|
  fill_in field, :with => value
end

Then(/^It works$/) do
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

############# Multi domains #####################
Given(/^I am not logged in in domain(\d+)$/) do |number|
  visit "/#{domain(number)}/auth/logout/#{domain(number)}"
end

When(/^I logout from domain(\d+)$/) do |number|
  visit "/#{domain(number)}/auth/logout/#{domain(number)}"
end

When(/^I visit domain(\d+) home page$/) do |number|
  visit "/#{domain(number)}/home"
end

Then(/^I am redirected to domain(\d+) login page$/) do |number|
  expect(current_path.match(/\/.+\/auth\/login/)).not_to be(nil)
end

Then(/^I am redirected to domain(\d+) home page$/) do |number|
  expect(current_path).to eq("/" + domain(number) + "/home")
end

Then(/^I see the domain(\d+) home page$/) do |number|
  expect(current_path).to eq("/" + domain(number) + "/home")
end

And(/^I notice the session id$/) do
  session_cookie = page.driver.cookies['_monsoon-dashboard_session']
  @session_cookie_id = session_cookie.value if session_cookie
end

And(/^the session id didn't change$/) do
  new_session_value = page.driver.cookies['_monsoon-dashboard_session'].value
  expect(@session_cookie_id).to eq(new_session_value)
end

And(/^the session path is domain(\d+)$/) do |number|
  session_cookie = page.driver.cookies['_monsoon-dashboard_session']
  expect("/#{domain(number)}").to eq(session_cookie.path)
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
