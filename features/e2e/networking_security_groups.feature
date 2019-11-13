@javascript
Feature: Security Groups
  Background:
    Given Test user has accepted terms of use
    Given I visit domain path "home"
     And I log in as test_user
    Then I am redirected to domain path "home"

  @admin
  Scenario: Can create a new Security Group
    When I visit project path "networking/security-groups/widget"
    Then I see "Security Groups"
    And All AJAX calls are successful
    And I see "New Security Group" button
    When I click on "New Security Group"
    Then I see "New Security Group"

  @member
  Scenario: Can not create a new Security Group
    When I visit project path "networking/security-groups/widget"
    Then I see "Security Groups"
    And I don't see a "New Security Group" button
