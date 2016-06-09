@javascript
Feature: Projects
  Background:
    Given I visit domain path "identity/home"
    Given I log in as test_user
    And I am redirected to domain path "identity/home"

  Scenario: User Projects page is reachable
    When I visit project path "/identity/home"
    Then the page status code is successful

  @member
  Scenario: Member buttons
    When I visit domain path "identity/home"
    Then I see "Request a New Project" button
    Then I see "Your Requests" button

  @member
  Scenario: Visit own requests
    When I visit domain path "identity/home"
    Then I see "Your Requests" button
    When I click on "Your Requests"
    Then the page status code is successful

  @admin
  Scenario: Create new Project
    When I visit domain path "identity/home"
    Then I see "Create a New Project" button
    When I click on "Create a New Project"
    Then the page status code is successful

  @admin
  Scenario: Visit own requests
    When I visit domain path "identity/home"
    Then I see "Your Requests" button
    When I click on "Your Requests"
    Then the page status code is successful

  @admin
  Scenario: Manage Requests
    When I visit domain path "identity/home"
    Then I see "Manage Requests" button
    When I click on "Manage Requests"
    Then the page status code is successful

  @admin
  Scenario: Manage Groups
    When I visit domain path "identity/home"
    Then I see "Manage Groups" button
    When I click on "Manage Groups"
    Then the page status code is successful

  @admin
  Scenario: Manage Resources
    When I visit domain path "identity/home"
    Then I see "Domain Resources Admin" button
    When I click on "Domain Resources Admin"
    Then the page status code is successful
