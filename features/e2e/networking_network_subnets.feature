@javascript
Feature: Subnets
  Background:
    Given I visit domain path "home"
     And I log in as test_user
    Given Test user has accepted terms of use
     And I visit project path "networking/networks/private"
     And the test network for subnets exists

  @admin
  Scenario: The Private Networks page is reachable
    When I click on manage subnets of test network
    Then I see "Manage Subnets"
