@javascript
Feature: Sign in
  In order to get access to protected sections of the site
  As an existing site member
  I Should be able to sign in

  Scenario: User is not signed up
    Given I do not exist as a user
    When I sign in with valid credentials
    Then I see "Email or password is invalid." message
    And I should be signed out

  Scenario: User signs in successfully
    Given I exist as a user
    And I am not signed in
    When I sign in with valid credentials
    Then I see "Welcome Sergei Zinin" message
    When I return to the home page
    Then I should be signed in

  Scenario: User enters wrong email
    Given I exist as a user
    And I am not signed in
    When I sign in with a wrong "notanemail" email
    Then I see "Email or password is invalid." message
    And I should be signed out

  Scenario: User enters wrong password
    Given I exist as a user
    And I am not signed in
    When I sign in with a wrong "wrongpassword" password
    Then I see "Email or password is invalid." message
    And I should be signed out
