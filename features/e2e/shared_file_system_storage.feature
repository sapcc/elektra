@javascript
Feature: Shared File System Storage
  Background:
    Given Test user has accepted terms of use
    Given I visit domain path "home"
    And I log in as test_user
    Then I am redirected to domain path "home"

  @admin
  Scenario: The Shared File System Storage page is reachable
    When I visit project path "shared-filesystem-storage"
    Then the page status code is successful
    And I see "Shared File System Storage"
    And All AJAX calls are successful
