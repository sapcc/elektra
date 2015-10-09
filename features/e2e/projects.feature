@javascript
Feature: Projects
  Background:
    Given User is logged in
    
  Scenario: Projects page is reachable
    When I visit "/monsooncc_test/projects"
    Then I see the projects page