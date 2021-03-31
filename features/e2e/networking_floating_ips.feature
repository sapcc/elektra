@javascript
Feature: Floating IP's
  Background:
    Given I visit domain path "home"
    And I log in as test_user
    Given Test user has accepted terms of use
    Then I am redirected to domain path "home"

  Scenario: The Floating IP's page is reachable
    When I visit project path "networking/floating_ips"
    Then the page status code is successful
    And I see "Floating IPs"

  @admin
  Scenario: New Floating IP Dialog comes up
    When I visit project path "networking/floating_ips"
    And I click on "Allocate new"
    And All AJAX calls are successful
    Then I see a selectbox with id "floating_ip_floating_network_id"
    And options of "floating_ip_floating_network_id" contains names and ids
    And I select the first option of "floating_ip_floating_network_id"
    And All AJAX calls are successful
    Then I see a selectbox with id "floating_ip_floating_subnet_id"
    And options of "floating_ip_floating_subnet_id" contains names and ids
