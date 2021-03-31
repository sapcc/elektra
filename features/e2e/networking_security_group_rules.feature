@javascript
Feature: Security Group Rules
  Background:
    Given I visit domain path "home"
     And I log in as test_user
    Given Test user has accepted terms of use


  @admin
  Scenario: Can create a new Security Group Rule
    When I visit project path "networking/security-groups/widget"
    Then the page status code is successful
    And All AJAX calls are successful
    And I see a "default" link
    When I click on "default"
    Then the page status code is successful
    And I see "Name: default"
    And I see "New Rule" button

  @member
  Scenario: Can not create a new Security Group Rule or remove the default ones
    When I visit project path "networking/security-groups/widget"
    Then the page status code is successful
    And All AJAX calls are successful
    And I see a "default" link
    When I click on "default"
    Then the page status code is successful
    And I see "Name: default"
    And I don't see a "New Rule" button
    And I don't see a "Remove" button
