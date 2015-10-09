Then(/I see the instances page/) do
  expect(page).to have_content("test_admin_sandbox - Instances")
end