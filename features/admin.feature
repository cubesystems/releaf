Feature: admin
  Background:
    Given I as an admin am logged in

  Scenario: Manage users
    When  I go to the releaf admins page
    Then  I should not see "john"
    And   I should see "Create new item"

    When  I follow "Create new item"
    And   fill in "Name" with "John"
    And   I press "Save"
    Then  I should be on Releaf::Admins#new
    Then  I should see "4 errors prohibited"


