@javascript
Feature: Authentication
  In order to avoid login errors
  I want to check the authentication functionality

  Scenario: User is not logged
    Given I am not logged in
    When I visit "/monsoon2"
    Then I see a "Log in" button

  Scenario: User is not logged in and tries to visit domain landing page
    Given I am on the root page
     And I am not logged in
    When I visit "/monsoon2/identity/home"
    Then I am redirected to login page
     And I see login form

  Scenario: User is not logged in but already registered
    Given I am not logged in
    When I visit "/monsoon2/identity/home"
     And Login as test_user
    Then I am redirected to "/monsoon2/identity/home"
     And I click on user navigation
     And I see a "Log out" button


  Scenario: User is redirected to the requested url after login
    Given I am not logged in
    When I visit "/monsoon2/identity/credentials"
     And Login as test_user
    Then I am redirected to "/monsoon2/identity/credentials"
