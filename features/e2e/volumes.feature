@javascript
Feature: Volumes
  Background:
    Given Test user has accepted terms of use
    Given I visit domain path "home"
    And I log in as test_user
    Then I am redirected to domain path "home"

  Scenario: The Volumes page is reachable
    When I visit project path "block-storage/#/volumes"
    Then the page status code is successful
     And All AJAX calls are successful
     And I see "Create New" button
    When I click on "Create New"
    Then the page status code is successful

  Scenario: The Snapshots page is reachable
    When I visit project path "block-storage/#/snapshots"
    Then the page status code is successful
     And All AJAX calls are successful
     And I see "Snapshots"
