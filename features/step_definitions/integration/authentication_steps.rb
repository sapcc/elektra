When(/^I fill in "(.*?)" as "(.*?)"/) do |value,field|
  fill_in field, :with => value
end

Then(/^I am redirected to login page$/) do
  expect(current_path).to eq(monsoon_openstack_auth.new_session_path)
end

Then(/^I see login form$/) do
  expect(page).to have_selector("form[action='#{monsoon_openstack_auth.sessions_path}']")
end

And(/^I click on user navigation$/) do
  first('a.navbar-identity').click
end

Then(/^It works$/) do
end

def current_path
  URI.parse(current_url).path
end



