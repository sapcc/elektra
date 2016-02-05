@javascript
Feature: Instances
  Background:
    Given I visit "/monsoon2/identity/home"
     And Login as test_user

  Scenario: Instances page is reachable
    When I visit "/monsoon2/dashboard_test_project/compute/instances"
    Then the page status code is successful
