@javascript
Feature: Security Groups
  Background:
    Given Test user has accepted terms of use
    Given I visit domain path "home"
     And I log in as test_user
    Then I am redirected to domain path "home"
    
  @admin
  Scenario: Can create a new Security Group
    When I visit project path "networking/security_groups"
    Then I see "Security Groups"
    And I see "Create new" button
    When I click on "Create new"
    Then I see "New Security Group"

  @member
  Scenario: Can not create a new Security Group
    When I visit project path "networking/security_groups"
    Then I see "Security Groups"
    And I don't see a "Create new" button  