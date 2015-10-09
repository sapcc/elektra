@javascript
Feature: Instances
  Background:
    Given User is logged in
    
  Scenario: Instances page is reachable
    When I visit "/monsooncc_test/test_admin_sandbox/instances"
    Then I see the instances page