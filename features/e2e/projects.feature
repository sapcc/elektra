@javascript
Feature: Projects
  Background:
    Given I visit domain path "identity/home"
    And I log in as test_user
    And I am redirected to domain path "identity/home"

  Scenario: User Projects page is reachable
    When I visit project path "/identity/home"
    Then the page status code is successful

  @member @wip
  Scenario: Request project button
    When I visit domain path "identity/home"
    Then I see "Request a New Project" button

  @admin @wip
  Scenario: Create project button
    When I visit domain path "identity/home"
    Then I see "Create a New Project" button

