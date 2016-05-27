@javascript
Feature: Networks
  Background:
    Given I visit "/monsoon2/identity/home"
     And I log as test_user
     And I am redirected to "/monsoon2/identity/home"

  Scenario: Networks page is reachable
    When I visit "/monsoon2/dashboard_test_project/networking/networks/private"
    Then the page status code is successful
