@javascript
Feature: Security Groups
  Background:
    Given Test user has accepted terms of use
    Given I visit domain path "identity/home"
     And I log in as test_user
    Then I am redirected to domain path "identity/home"
    
  Scenario: The Security Groups Page is reachable
    When I visit project path "networking/security_groups"
    Then the page status code is successful
    And I see "Security Groups"
    
  @admin
  Scenario: Can create a new Security Group
    When I visit project path "networking/security_groups"
    Then the page status code is successful
    And I see "Create new" button
    When I click on "Create new"
    Then the page status code is successful
    And I see "New Security Group"

  @member
  Scenario: Can not create a new Security Group
    When I visit project path "networking/security_groups"
    Then the page status code is successful
    And I don't see a "Create new" button  