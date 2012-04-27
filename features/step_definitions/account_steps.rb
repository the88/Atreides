Given /^I am not authenticated$/ do
  visit('/users/sign_out') # ensure that at least
end

Given /^I have one\s+user "([^\"]*)" with password "([^\"]*)" and login "([^\"]*)"$/ do |email, password, login|
  Atreides::User.new(:email => email,
           :login => login,
           :password => password,
           :password_confirmation => password).save!
end

Then /^dump_users$/ do
  puts Atreides::User.all.inspect
end

Given /^the following accounts:$/ do |accounts|
  Atreides::User.create!(accounts.hashes)
end

Given /^I am authenticated as "([^"]*)" with "([^"]*)"$/ do |email, password|
  visit destroy_user_session_path
  visit new_user_session_path
  steps %Q{
    And I fill in "user_email" with "#{email}"
    And I fill in "user_password" with "#{password}"
    And I press "Login"
  }
end


When /^I delete the (\d+)(?:st|nd|rd|th) account$/ do |pos|
  visit accounts_path
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following accounts:$/ do |expected_accounts_table|
  expected_accounts_table.diff!(tableish('table tr', 'td,th'))
end
