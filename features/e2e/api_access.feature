@javascript
Feature: API Access
  Background:
    Given I visit domain path "home"
    And I log in as test_user
    Given Test user has accepted terms of use
    Then I am redirected to domain path "home"

  @wip
  Scenario: The Web Console page is reachable
    When I visit project path "webconsole"
    Then the page status code is successful
    And I see "Web Shell"

  Scenario: The Api Endpoints page is reachable
    When I visit project path "identity/projects/api-endpoints"
    Then the page status code is successful
    And I see "OS_AUTH_URL"
