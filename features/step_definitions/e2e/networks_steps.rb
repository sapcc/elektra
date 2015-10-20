Then(/I see the networks page/) do
  expect(page).to have_content("test_admin_sandbox - Networks")
end