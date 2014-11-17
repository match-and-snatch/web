@javascript
Feature: Sign up
  In order to get access to protected sections of the site
  As not a site member
  I Should be able to register

  Scenario: User signs up successfully
    When I sign up with credentials:
      | first_name | last_name | email            | password | password_confirmation |
      | dimon      | medvedev  | dimon@medved.com | password | password              |
    Then I should see "Your profile is almost complete!" message

  Scenario Outline: User signs up with invalid credentials
    When I sign up with credentials:
      | first_name   | last_name   | email   | password   | password_confirmation   |
      | <first_name> | <last_name> | <email> | <password> | <password_confirmation> |
    Then I should see "<message>" message
    And I am not signed in

    Examples:
      | first_name | last_name | email            | password | password_confirmation | message                                |
      |            | medvedev  | dimon@medved.com | password | password              | This cannot be empty.                  |
      | dimon      |           | dimon@medved.com | password | password              | This cannot be empty.                  |
      | dimon      | medvedev  |                  | password | password              | This cannot be empty.                  |
      | dimon      | medvedev  | dimon@medved.com |          | password              | Please enter at least 5 characters.    |
      | dimon      | medvedev  | dimon@medved.com | password |                       | Does not match password.               |
      | dimon      | medvedev  | dimon@medved.com | password | wronpassword          | Does not match password.               |
      | dimon      | medvedev  | dimon@medved     | password | password              | This is not valid.                     |
