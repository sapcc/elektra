@javascript
Feature: DNS
  Background:
    Given I visit domain path "identity/home"
    And I log in as test_user
    And I am redirected to domain path "identity/home"

  Scenario: The DNS page is reachable
    When I visit project path "dns-service"
    Then the page status code is successful
    And I see "DNS"

