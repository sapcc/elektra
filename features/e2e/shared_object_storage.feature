@javascript
Feature: Shared Object Storage
  Background:
    Given Test user has accepted terms of use
    Given I visit domain path "home"
    And I log in as test_user
    Then I am redirected to domain path "home"

  Scenario: The Shared Object Storage page is reachable
    When I visit project path "object-storage"
    Then the page status code is successful

