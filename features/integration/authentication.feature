@javascript
Feature: Authentication
  In order to avoid login errors
  I want to check the authentication functionality
  
  Scenario: User is not logged in
    Given I am on the root page
     And I am not logged in
    When I visit "/monsooncc_test/start"
    Then I am redirected to login page
    And I see login form