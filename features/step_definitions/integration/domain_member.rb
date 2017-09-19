Then(/^I see "(.+)?" button$/) do |button_label|
  expect(page).to have_content button_label
end

Then(/^I see "(.+)?"$/) do |text|
  expect(page).to have_content text
end
