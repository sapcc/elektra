@javascript
Feature: Health 

  Scenario: Health Check is OK
    When I go to the health check 
    Then I should see "ok"
