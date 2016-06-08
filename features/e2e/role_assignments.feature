@javascript
Feature: Role Assignments
  Background:
    Given I visit domain path "identity/home"
    And I log in as test_user
    And I am redirected to domain path "identity/home"

  Scenario: The Project Members page is reachable
    When I visit project path "identity/projects/members"
    Then the page status code is successful

  Scenario: The Project Groups page is reachable
    When I visit project path "identity/projects/groups"
    Then the page status code is successful

