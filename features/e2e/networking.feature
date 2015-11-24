@javascript
Feature: Networks
  Background:
    Given I visit "/monsooncc_test/home"
     And Login as test_admin

  Scenario: Networks page is reachable
    When I visit "/monsooncc_test/test_admin_sandbox/networking/networks"
    Then I see the networks page
