Given(/^the test network for subnets exists$/) do
  unless page.has_content? 'Test Network For Subnets'
    # create test network
    click_on 'Create new'
    fill_in 'network[name]', with: 'Test Network For Subnets'
    fill_in 'network[subnets][name]', with: 'Test Network For Subnets Subnet1'
    fill_in 'network[subnets][cidr]', with: '10.180.0.0/8'
    click_on 'Create'
  end
end

When(/^I click on manage subnets of test network$/) do
  tr = find('tr', text: 'Test Network For Subnets').first
  within(tr) do
    find('.btn-group .btn.btn-default.btn-sm.dropdown-toggle').click
    click_on 'Manage Subnets'
  end
end
