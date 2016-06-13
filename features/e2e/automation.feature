@javascript
Feature: Automation
  Background:
    Given I visit domain path "identity/home"
    And I log in as test_user
    And I am redirected to domain path "identity/home"

  Scenario: The Nodes page is reachable
    When I visit project path "automation/nodes"
    Then the page status code is successful
    And I see "Add Node"

  Scenario: The Automations page is reachable
    When I visit project path "automation/automations"
    Then the page status code is successful
    And I see "Available Automations"


