@javascript
Feature: Images
  Background:
    Given Test user has accepted terms of use
    Given I visit domain path "home"
    And I log in as test_user
    Then I am redirected to domain path "home"

  Scenario: The Images page is reachable
    When I visit project path "image/os_images/public"
    Then the page status code is successful
    And I see "Images"

  @admin
  Scenario: The next generation images page is reachable
    When I visit project path "/image/ng"
    Then the page status code is successful
    And I see "Server Images & Snapshots"
    And All AJAX calls are successful
