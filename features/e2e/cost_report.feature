@javascript
Feature: Cost Report
  Background:
    Given Test user has accepted terms of use
    Given I visit domain path "home"
     And I log in as test_user
    Then I am redirected to domain path "home"

  @admin
  Scenario: The domain Cost Report page is reachable
    When I visit domain path "/reports/cost/domain"
    Then the page status code is successful
    And I see "Cost Report"
    And I don't see "Request failed"

  @admin
  Scenario: The project Cost Report page is reachable
    When I visit project path "/reports/cost/project"
    Then the page status code is successful
    And I see "Cost Report"
    And I don't see "Request failed"
