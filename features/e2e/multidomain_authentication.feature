# @javascript
# Feature: Multi Domain Authentication
#   In order to test that the user can be logged in in several OpenStack domains at the same time
#   I want to check the multi domain authentication
#
#   Scenario: User signs in in two Openstack domains simultaneously
#     Given I am not logged in in domain1
#      And I am not logged in in domain2
#     When I visit domain1 home page
#     Then I am redirected to domain1 login page
#     When I log in as test_user
#     Then I am redirected to domain1 home page
#      And the session path is domain1
#     When I visit domain2 home page
#     Then I am redirected to domain2 login page
#     When I log in as test_user
#     Then I am redirected to domain2 home page
#      And the session path is domain2
#     When I visit domain1 home page
#     Then I see the domain1 home page
#
#   Scenario: When the user logs out in a domain all other domain sessions remain intact
#     Given I am not logged in in domain1
#      And I am not logged in in domain2
#      And I visit domain1 home page
#      And I am redirected to domain1 login page
#      And I log in as test_user
#      And I am redirected to domain1 home page
#      And I visit domain2 home page
#      And I am redirected to domain2 login page
#      And I log in as test_user
#      And I am redirected to domain2 home page
#     When I logout from domain2
#      And I visit domain1 home page
#     Then I see the domain1 home page
#
#   Scenario: Session ID is not affected by logout in other domain
#     Given I am not logged in in domain1
#      And I visit domain1 home page
#      And I am redirected to domain1 login page
#      And I log in as test_user
#      And I am redirected to domain1 home page
#      And I notice the session id
#      And I am not logged in in domain2
#      And I visit domain2 home page
#      And I am redirected to domain2 login page
#      And I log in as test_user
#      And I am redirected to domain2 home page
#     When I logout from domain2
#      And I visit domain1 home page
#     Then I see the domain1 home page
#      And the session id didn't change
