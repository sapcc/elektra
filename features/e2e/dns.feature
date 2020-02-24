@javascript
Feature: DNS
  Background:
    Given Test user has accepted terms of use
    Given I visit domain path "home"
    And I log in as test_user
    Then I am redirected to domain path "home"

  Scenario: The DNS page is reachable
    When I visit project path "dns-service/zones"
    Then the page status code is successful
    And I see "DNS"

  Scenario: Request New Domain Button is visible
    When I visit project path "dns-service/zones"
    Then I see a "Request New Domain" button

  Scenario: The Request Domain Dialog comes up
    When I visit project path "dns-service/zones"
    And I click on "Request New Domain"
    Then I see "Request New Domain"

  Scenario: Domain Pool in Request Domain Dialog
    When I visit project path "dns-service/zones"
    And I click on "Request New Domain"
    Then I see "DNS Provider"

  Scenario: Form for subdomain in Request Domain Dialog
    When I visit project path "dns-service/zones"
    And I click on "Request New Domain"
    And I select "Internal SAP Hosted Zone" from "zone_request_domain_pool"
    And I choose "Subdomain" radiobutton
    Then I see "Domain Name"
     And I see select "zone_request_dns_domain"

  Scenario: Form for custom domain in Request Zone Dialog
    When I visit project path "dns-service/zones"
    And I click on "Request New Zone"
    And I select "Internal SAP Hosted Zone" from "zone_request_domain_pool"
    And I choose "Custom Domain" radiobutton
    Then I see "Domain Name"
