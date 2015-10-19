@javascript
Feature: Sign up
  In order to get access to protected sections of the site
  As not a site member
  I Should be able to register

  Scenario: User signs up successfully
    When I sign up with credentials:
      | first_name | last_name | email            | password |
      | dimon      | medvedev  | dimon@medved.com | password |
    Then I should see "Your profile is almost complete!" message

  Scenario Outline: User signs up with invalid credentials
    When I sign up with credentials:
      | first_name   | last_name   | email   | password   |
      | <first_name> | <last_name> | <email> | <password> |
    Then I should see "<message>" message
    And I am not signed in

    Examples:
      | first_name | last_name | email            | password | message                                |
      |            | medvedev  | dimon@medved.com | password | This cannot be empty.                  |
      | dimon      |           | dimon@medved.com | password | This cannot be empty.                  |
      | dimon      | medvedev  |                  | password | This cannot be empty.                  |
      | dimon      | medvedev  | dimon@medved.com |          | Please enter at least 5 characters.    |
      | dimon      | medvedev  | dimon@medved     | password | This is not valid.                     |
