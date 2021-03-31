@javascript
Feature: Networks
  Background:
    Given I visit domain path "home"
     And I log in as test_user
    Given Test user has accepted terms of use
    Then I am redirected to domain path "home"

  Scenario: The Private Networks page is reachable
    When I visit project path "networking/networks/private"
    Then the page status code is successful
    And I see "Networks"

  @admin
  Scenario: The Private Networks page is reachable
    When I visit project path "networking/networks/private"
    Then the page status code is successful
    And I see "Create new" button
    When I click on "Create new"
    Then the page status code is successful
    And I see "Network Name"

 Scenario: The External Networks page is reachable
    When I visit project path "networking/networks/external"
    Then the page status code is successful
    And I see "Networks"

 Scenario: The Routers page is reachable
    When I visit project path "networking/routers"
    Then the page status code is successful
    And I see "Networks"