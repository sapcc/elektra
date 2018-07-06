When(/^I search for any object$/) do
  fill_in 'searchValue', :with => 'any object'
  click_on 'Find Object'
end
