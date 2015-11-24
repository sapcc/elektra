@javascript
Feature: Authentication
  In order to avoid login errors
  I want to check the authentication functionality

  Scenario: User is not logged
    Given I am not logged in
    When I visit "/monsooncc_test"
    Then I see a "Log in" button

  Scenario: User is not logged in and tries to visit domain landing page
    Given I am on the root page
     And I am not logged in
    When I visit "/monsooncc_test/home"
    Then I am redirected to login page
     And I see login form

  Scenario: User is not logged in but already registered
    Given I am not logged in
    When I visit "/monsooncc_test/home"
     And Login as test_admin
    Then I am redirected to "/monsooncc_test/home"
     And I click on user navigation
     And I see a "Log out" button


  Scenario: User is redirected to the requested url after login
    Given I am not logged in
    When I visit "/monsooncc_test/identity/credentials"
     And Login as test_admin
    Then I am redirected to "/monsooncc_test/identity/credentials"
