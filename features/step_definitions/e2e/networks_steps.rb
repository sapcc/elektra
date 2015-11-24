Then(/I see the networks page/) do
  within(".main-toolbar") do
    expect(page).to have_content("Networks")
  end
end
