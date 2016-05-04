@javascript
Feature: Domain Member
  Background:
    Given I visit "/monsoon2/identity/home"
     And I log as test_user
     And I am redirected to "/monsoon2/identity/home"

  Scenario: Request project button
    When I visit "/monsoon2/identity/home"
    Then I see "Request a New Project" button
