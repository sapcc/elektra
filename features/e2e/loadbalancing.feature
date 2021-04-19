@javascript
Feature: Load Balancing
  Background:
    Given I visit domain path "home"
    And I log in as test_user
    Given Test user has accepted terms of use
    Then I am redirected to domain path "home"

  Scenario: The Loadbalancers page is reachable
    When I visit project path "/lbaas2"
    Then the page status code is successful
    And I see "Load Balancers"

