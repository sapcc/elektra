@javascript
Feature: Networks
  Background:
    Given User is logged in
    
  Scenario: Networks page is reachable
    When I visit "/monsooncc_test/test_admin_sandbox/networks"
    Then I see the networks page