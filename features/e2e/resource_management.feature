@javascript
Feature: Resource Management
  Background:
    Given I visit domain path "identity/home"
    And I log in as test_user
    And I am redirected to domain path "identity/home"

  Scenario: The Resource Management page is reachable
    When I visit project path "resource-management"
    Then the page status code is successful

