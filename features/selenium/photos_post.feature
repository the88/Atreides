Feature: Add a photo gallery
  In order to animate the blog
  An administrative user
  wants to add a photo gallery

  # Background:
  #   Given the following accounts:
  #     | email                    | first_name | last_name         | password |  admin  |
  #     | contact@lovethe88.com    | The88      | Agency            | ******** |  true   |
  #     | non_admin@lovethe88.com  | normal     | user              | ******** |  false  |
  #     | non_admin2@lovethe88.com | normal     | user 2            | ******** |  false  |
  #     | deletable@lovethe88.com  | deletable  | user              | ******** |  true   |

  @javascript
  @firebug
  @wip
  Scenario: Add a photo gallery
    Given the following accounts:
      | email                   | first_name | last_name         | password |  admin  |
      | terry@lovethe88.com     | Terry      | Richardson        | ******** |  true   |
    Given I am authenticated as "terry@lovethe88.com" with "********"
    Given I am on the new photos post page
    Then pause 100 seconds
    
    # Given I am on the new post admin page
    