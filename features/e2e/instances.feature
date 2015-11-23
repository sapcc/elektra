@javascript
Feature: Instances
  Background:
    Given I visit "/monsooncc_test/home"
     And Login as test_admin

  Scenario: Instances page is reachable
    When I visit "/monsooncc_test/test_admin_sandbox/compute/instances"
    Then I see the instances page
