@javascript
Feature: Reverse Lookup
  Background:
    Given I visit domain path "home"
     And I log in as test_user
    Given Test user has accepted terms of use
    Then I am redirected to domain path "home"

  @admin
  Scenario: The Reverse Lookup page is reachable
    When I visit domain path "/lookup/reverselookup"
    Then the page status code is successful
    When I search for any object
    Then I don't see "Request failed with status code 500"

  #@admin
  #Scenario: The Reverse Lookup page is reachable
  #  When I visit domain path "/home?overlay=/cc3test/lookup/reverselookup"
  #  Then the page status code is successful
  #  When I search for any object
  #  Then I don't see "Request failed with status code 500"
