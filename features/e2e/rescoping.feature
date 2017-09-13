@javascript
Feature: Rescoping
  In order to avoid scope errors
  I want to check the rescope logic

  Background:
    Given I am not logged in
      And I visit domain path "home"
      And I log in as test_user
      And Test user has accepted terms of use

  Scenario: Domain is provided and project not and user has access to domain
    Then I see the domain home page

  Scenario: Domain is provided and project not and domain exists
    When I visit path "/ccadmin/identity/home"
    Then I am redirected to login page

  Scenario: Domain is provided and project not and domain does not exist
    When I visit path "/BAD_DOMAIN/identity/home"
    Then I see warning "Unsupported Domain"

  Scenario: Domain and project are provied and user has access to domain but not to project
    When I visit domain path "BAD_PROJECT/identity/project/home"
    Then I see warning "Project Not Found"

  Scenario: Domain and project are provied and user has no access to domain and project
    When I visit path "/BAD_DOMAIN/BAD_PROJECT/identity/project/home"
    Then I see warning "Unsupported Domain"
