@javascript
Feature: Ports
  Background:
    Given Test user has accepted terms of use
    Given I visit domain path "home"
    And I log in as test_user
    Then I am redirected to domain path "home"

  @admin
  Scenario: The ports page is reachable
    When I visit project path "/networking/ports"
    Then the page status code is successful
    And I see "Fixed IPs / Ports"
    And All AJAX calls are successful
