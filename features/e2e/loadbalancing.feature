@javascript
Feature: Load Balancing
  Background:
    Given I visit domain path "identity/home"
    And I log in as test_user
    And I am redirected to domain path "identity/home"

  Scenario: The Floating IP's page is reachable
    When I visit project path "loadbalancing"
    Then the page status code is successful

