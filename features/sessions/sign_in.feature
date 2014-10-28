@javascript
Feature: Sign in
  In order to get access to protected sections of the site
  As an existing site member
  I Should be able to sign in

  Background:
    Given I exist as a user:
      | first_name | last_name | email           | password | password_confirmation |
      | sergei     | zinin     | serge@gmail.com | password | password              |

    And I am not signed in

  Scenario: User is not signed up
    Given I do not exist as a user
    When I sign in with credentials:
      | email           | password |
      | serge@gmail.com | password |

    Then I see "Email or password is invalid." message
    And I should be signed out

  Scenario: User signs in successfully
    When I sign in with credentials:
      | email           | password |
      | serge@gmail.com | password |

    Then I see "Welcome Sergei Zinin" message
    When I return to the home page
    Then I should be signed in

  Scenario: User enters wrong email
    When I sign in with credentials:
      | email           | password      |
      | serge@gmail.com | wrongpassword |

    Then I see "Email or password is invalid." message
    And I should be signed out

  Scenario: User enters wrong password
    When I sign in with credentials:
      | email      | password |
      | notanemail | password |

    Then I see "Email or password is invalid." message
    And I should be signed out
