Then(/I see the projects page/) do
  expect(page).to have_content("Projects")
end