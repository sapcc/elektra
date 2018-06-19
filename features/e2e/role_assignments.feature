@javascript
Feature: Role Assignments
  Background:
    Given Test user has accepted terms of use
    Given I visit domain path "home"
    And I log in as test_user
    Then I am redirected to domain path "home"

  Scenario: The project user role assignments page is reachable
    When I visit project path "identity/projects/role-assignments"
    Then the page status code is successful
    And I see "User"

  Scenario: The project group role assignments page is reachable
    When I visit project path "identity/projects/role-assignments?active_tab=groupRoles"
    Then the page status code is successful
    And I see "Group"

  @admin
  Scenario: Add new member to project user role assignments
    When I visit project path "identity/projects/role-assignments"
    Then I see "Add New Member" button

  @admin
  Scenario: Add new member to project group role assignments
    When I visit project path "identity/projects/role-assignments?active_tab=groupRoles"
    Then I see "Add new Member" button
