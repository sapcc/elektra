@javascript
Feature: Shared Object Storage
  Background:
    Given Test user has accepted terms of use
    Given I visit domain path "identity/home"
    And I log in as test_user
    Then I am redirected to domain path "identity/home"

  Scenario: The Shared Object Storage page is reachable
    When I visit project path "object-storage"
    Then the page status code is successful

