@javascript
Feature: Monitoring

  Background:
    Given I visit domain path "identity/home"
    And I log in as test_user
    And I am redirected to domain path "identity/home"

  Scenario: The Monitoring page is reachable
    When I visit project path "monitoring"
    Then the page status code is successful
     And I see "Monitoring"
