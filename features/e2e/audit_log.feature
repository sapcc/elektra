@javascript
Feature: Audit Log
  Background:
    Given I visit domain path "home"
     And I log in as test_user
    Given Test user has accepted terms of use
    Then I am redirected to domain path "home"

  @admin
  Scenario: The Audit Log page is reachable
    When I visit project path "audit/"
    Then the page status code is successful
    And I see "Audit Log"
