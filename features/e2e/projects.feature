@javascript
Feature: Projects
  Background:
    Given I visit "/monsooncc_test/start"
     And Login as test_admin
    
  Scenario: Projects page is reachable
    When I visit "/monsooncc_test/identity/projects"
    Then I see the projects page