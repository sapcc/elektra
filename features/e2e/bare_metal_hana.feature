# @javascript
# Feature: Bare Metal Hana
#   Background:
#     Given I visit domain path "home"
#     And I log in as test_user
#     Given Test user has accepted terms of use
#     Then I am redirected to domain path "home"
#
#   Scenario: The Bare-Metal-Hana page is reachable
#     When I visit project path "bare-metal-hana"
#     Then the page status code is successful
#     And I see "HANA Servers"
