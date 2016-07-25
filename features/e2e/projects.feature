@javascript
Feature: Projects
  Background:
    Given Test user has accepted terms of use
    Given I visit domain path "identity/home"
    And I log in as test_user
    Then I am redirected to domain path "identity/home"

  Scenario: User Projects page is reachable
    When I visit project path "identity/home"
    Then I am redirected to project path "identity/home"

  @member
  Scenario: Member buttons
    When I visit domain path "identity/home"
    Then I see "Request a New Project" button
    And  I see "Your Requests" button

  @member
  Scenario: Visit own requests
    When I visit domain path "identity/home"
    Then I see "Your Requests" button
    When I click on "Your Requests"
    Then I see "Your Requests"

  @admin
  Scenario: Create new Project
    When I visit domain path "identity/home"
    Then I see "Create a New Project" button
    When I click on "Create a New Project"
    Then the page status code is successful
    And  I see "Create new project"

  @admin
  Scenario: Visit own requests
    When I visit domain path "identity/home"
    Then I see "Your Requests" button
    When I click on "Your Requests"
    Then the page status code is successful
    And  I see "Your Requests"

  @admin
  Scenario: Manage Requests
    When I visit domain path "identity/home"
    Then I see "Manage Requests" button
    When I click on "Manage Requests"
    Then the page status code is successful
    And  I see "Requests for processing"

  @admin
  Scenario: Group Management
    When I visit domain path "identity/home"
    Then I see "Group Management" button
    When I click on "Group Management"
    Then the page status code is successful
    And  I see "Groups"

  @admin
  Scenario: Manage Resources
    When I visit domain path "identity/home"
    Then I see "Domain Resources Admin" button
    When I click on "Domain Resources Admin"
    Then the page status code is successful
    And  I see "Manage Domain Resources"
