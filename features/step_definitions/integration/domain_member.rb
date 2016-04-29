Then(/^I see "(.+)?" button$/) do |button_label|
  expect(page).to have_content button_label
end


