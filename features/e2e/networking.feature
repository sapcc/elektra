@javascript
Feature: Networks
  Background:
    Given I visit domain path "identity/home"
     And I log in as test_user
     And I am redirected to domain path "identity/home"

  Scenario: The Private Networks page is reachable
    When I visit project path "networking/networks/private"
    Then the page status code is successful

 Scenario: The External Networks page is reachable
    When I visit project path "networking/networks/external"
    Then the page status code is successful

 Scenario: The Routers page is reachable
    When I visit project path "networking/routers"
    Then the page status code is successful
