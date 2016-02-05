@javascript
Feature: Networks
  Background:
    Given I visit "/monsoon2/identity/home"
     And Login as test_user

  Scenario: Networks page is reachable
    When I visit "/monsoon2/dashboard_test_project/networking/networks"
    Then the page status code is successful
