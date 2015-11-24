Then(/I see the instances page/) do
  within(".main-toolbar") do
    expect(page).to have_content("Instances")
  end
end
