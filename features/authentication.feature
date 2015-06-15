Feature: Authentication
  In order to avoid login errors
  I want to check the authentication functionality
  
  Scenario: User is not logged in
    Given I am not logged in
    When I visit "/instances"
    Then I am redirected to login page
    And I see login form