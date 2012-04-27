Factory.define :user, :class => Atreides::User do |user|
  user.sequence(:email)      { |n| "user-#{n}@test.com" }
  user.first_name            "Mr"
  user.last_name             "Tester"
  user.password              "secretpassword"
  user.password_confirmation "secretpassword"
end

Factory.define :user_admin, :parent => :user, :class => Atreides::User do |user|
  user.first_name            "Admin"
  user.last_name             "Tester"
  user.role                  "admin"
end

Factory.define :user_editor, :parent => :user, :class => Atreides::User do |user|
  user.first_name            "Editor"
  user.last_name             "Tester"
  user.role                  "editor"
end

Factory.define :user_writer, :parent => :user, :class => Atreides::User do |user|
  user.first_name            "Writer"
  user.last_name             "Tester"
  user.role                  "writer"
end
