@javascript
Feature: Restore password
  In order to get access to the site
  As an existing site member
  I Should be able to restore forgotten password

  Background:
    Given I exist as a user:
      | first_name | last_name | email           | password | password_confirmation |
      | sergei     | zinin     | serge@gmail.com | password | password              |

    And I am not signed in

  Scenario: User enters valid email
    When I try to restore password with email "serge@gmail.com"
    Then I should see "We sent you an email on serge@gmail.com with futher steps to restore your password." message
    And  I should be signed out

  Scenario Outline: User enters invalid email
    When I try to restore password with email "<email>"
    Then I should see "<message>" message
    And  I should be signed out

    Examples:
      | email         | message                                      |
      | dimon@mail.ru | There is no user registered with this email. |
      | dimon@mail    | This is not valid.                           |
      |               | This is not valid.                           |
