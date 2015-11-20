@javascript
Feature: Credentials
  Background:
    Given I visit "/monsooncc_test/home"
     And Login as test_admin

  Scenario: Credentials page is reachable
    When I visit "/monsooncc_test/identity/credentials"
    Then I see the credentials page
