@javascript
Feature: Images
  Background:
    Given I visit domain path "identity/home"
    And I log in as test_user
    And I am redirected to domain path "identity/home"

  Scenario: The Images page is reachable
    When I visit project path "image/os_images/public"
    Then the page status code is successful
    And I see "Images"

