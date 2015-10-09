@javascript
Feature: Credentials
  Background:
    Given User is logged in
    
  Scenario: Credentials page is reachable
    When I visit "/monsooncc_test/credentials"
    Then I see the credentials page