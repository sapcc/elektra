@javascript
Feature: Volumes
  Background:
    Given I visit domain path "home"
    And I log in as test_user
    Given Test user has accepted terms of use
    Then I am redirected to domain path "home"

  Scenario: The Volumes page is reachable
    When I visit project path "block-storage/?r=/volumes"
    Then the page status code is successful
     And All AJAX calls are successful
     And I see "Create New" button
    When I click on "Create New"
    Then the page status code is successful

  Scenario: The Snapshots page is reachable
    When I visit project path "block-storage/?r=/snapshots"
    Then the page status code is successful
     And All AJAX calls are successful
     And I see "Snapshots"
