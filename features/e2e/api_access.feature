@javascript
Feature: API Access
  Background:
    Given I visit domain path "identity/home"
    And I log in as test_user
    And I am redirected to domain path "identity/home"

  Scenario: The Web Console page is reachable
    When I visit project path "webconsole"
    Then the page status code is successful
    And I see "Web Console"

  Scenario: The Api Endpoints page is reachable
    When I visit project path "identity/projects/api-endpoints"
    Then the page status code is successful
    And I see "OS_AUTH_URL"
