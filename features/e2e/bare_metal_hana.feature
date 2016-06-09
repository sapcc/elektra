@javascript
Feature: Api Access
  Background:
    Given I visit domain path "identity/home"
    And I log in as test_user
    And I am redirected to domain path "identity/home"

  Scenario: The Bare-Metal-Hana page is reachable
    When I visit project path "bare-metal-hana"
    Then the page status code is successful
