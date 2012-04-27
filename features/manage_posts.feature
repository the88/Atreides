Feature: Manage posts
  In order to animate its Atreides
  An administrative user
  wants to add, edit and delete posts
  
  Background:
    Given the following accounts:
      | email                   | first_name | last_name         | password |  admin  |
      | terry@lovethe88.com     | Terry      | Richardson        | ******** |  true   |
    And I am authenticated as "terry@lovethe88.com" with "********"
    And the following posts:
      | title         |                   body                    | post_type   |    state    |
      | Hey guys      | Nevermind, just testing my new site.      | post        |  published  |
      | New expo      | Do not miss it !!!                        | post        |  published  |
      | My draft      | Not ready for prime time yet...           | post        |  drafted    |

  Scenario: List the published posts
    Given I am on the posts admin page
    # Then show me the posts
    Then I should see "Hey guys"
    And  I should see "New expo"
  
  Scenario: List the drafted posts
    Given I am on the drafted admin posts page
    Then show me the posts
    And I should see "My draft"
  
  Scenario: Create a post
    Given I am on the posts admin page
    And I follow "Post"
    When I fill in the following:
      | Title       | New event     |
      | Body        | Come join us! |
    And I press "Save"
    Then I should see "New event"
    # Then I should see "Successfully updated!"
  
  Scenario: Delete a post
    Given I am on the posts admin page
    When I follow "New expo"
    Then I should see "New Post"
    When I follow "Delete"
    Then I should see "successfully"
