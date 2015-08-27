@javascript
Feature: Dashboard Happy Path

  Scenario: Landing Page
    When I go to the homepage
    Then I should see "Openstack Cloud"
