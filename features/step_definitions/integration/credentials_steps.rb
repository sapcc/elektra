Then(/I see the credentials page/) do
  expect(page).to have_content("Credentials")
end