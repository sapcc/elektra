When(/^I go to the health check$/) do
  visit "/system/health"
end

When(/^I go to the system path "(.*?)"$/) do |value|
  visit "/system/#{value}"
end
