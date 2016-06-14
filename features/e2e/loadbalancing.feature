@javascript
Feature: Load Balancing
  Background:
    Given Test user has accepted terms of use
    Given I visit domain path "identity/home"
    And I log in as test_user
    Then I am redirected to domain path "identity/home"

  Scenario: The Floating IP's page is reachable
    When I visit project path "loadbalancing"
    Then the page status code is successful
    And I see "Loadbalancing"

