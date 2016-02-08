@javascript
Feature: Projects
  Background:
    Given I visit "/monsoon2/identity/home"
     And Login as test_user

  Scenario: Projects page is reachable
    When I visit "/monsoon2/identity/projects"
    Then the page status code is successful
