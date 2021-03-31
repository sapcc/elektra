@javascript
Feature: Authentication
  In order to avoid login errors
  I want to check the authentication functionality

  Scenario: User is not logged
    Given I am not logged in
    When I visit the test domain
    Then I see a "Log in" button

  Scenario: User is not logged in and tries to visit domain landing page
    Given I am on the root page
     And I am not logged in
    When I visit domain path "home"
    Then I am redirected to login page
     And I see login form

  Scenario: User is not logged in but already accepted terms of use
    Given I am not logged in
    When I visit domain path "home"
     And I log in as test_user
    Given Test user has accepted terms of use
    Then I am redirected to domain path "home"
     And I click on user navigation
     And I see a "Log out" button

  @admin
  Scenario: User is redirected to the requested url after login
    Given Test user has accepted terms of use
    Given I am not logged in
    When I visit domain path "identity/home"
     And I log in as test_user
    Then I am redirected to domain path "identity/home"

  @wip
  Scenario: User is not logged in has not accepted terms of use
    Given I am not logged in
    When I visit domain path "home"
    And I log in as test_user
    Then I am redirected to domain path "home"
    And I see "Terms"
