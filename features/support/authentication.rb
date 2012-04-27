Before('@as_admin') do
  steps %Q{
    Given the following accounts:
      | email                   | first_name | last_name         | password |  admin  |
      | terry@lovethe88.com     | Terry      | Richardson        | ******** |  true   |
    Given I am authenticated as "terry@lovethe88.com" with "********"
  }
end
