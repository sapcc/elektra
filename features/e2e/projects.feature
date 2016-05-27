@javascript
Feature: Projects
  Background:
    Given I visit "/monsoon2/identity/home"
     And I log as test_user
     And I am redirected to "/monsoon2/identity/home"

  Scenario: User Projects page is reachable
    When I visit "/monsoon2/identity/user-projects"
    Then the page status code is successful
