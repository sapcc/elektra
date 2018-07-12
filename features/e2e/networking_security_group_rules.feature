@javascript
Feature: Security Group Rules
  Background:
    Given Test user has accepted terms of use
    Given I visit domain path "home"
     And I log in as test_user


  @admin
  Scenario: Can create a new Security Group Rule
    When I visit project path "networking/security_groups"
    Then the page status code is successful
    And I see a "default" link
    When I click on "default"
    Then the page status code is successful
    And I see "Security Groups / default"
    And I see "New Rule" button

  @member
  Scenario: Can not create a new Security Group Rule or remove the default ones
    When I visit project path "networking/security_groups"
    Then the page status code is successful
    And I see a "default" link
    When I click on "default"
    Then the page status code is successful
    And I see "Security Groups / default"
    And I don't see a "New Rule" button
    And I don't see a "Remove" button
