@javascript
Feature: Multi Domain Authentication
  In order to test that the user can be logged in in several OpenStack domains at the same time
  I want to check the multi domain authentication

  Scenario: User signs in in two Openstack domains simultaneously
    Given I am not logged in in domain1
     And I am not logged in in domain2
    When I visit domain1 home page
    Then I am redirected to domain1 login page
