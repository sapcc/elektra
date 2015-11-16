When(/^I fill in "(.*?)" as "(.*?)"/) do |value,field|
  fill_in field, :with => value
end

Then(/^I am redirected to login page for "(.*?)"$/) do |domain_id|
  expect(current_path.start_with(monsoon_openstack_auth.login_path)).to eq(true)
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



