module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'
    when /the new photos post page/
      admin_new_content_path :type => 'photos'
    when /the new account page/
      admin_new_user_path
    when /the drafted admin posts page/
      filter_admin_posts_path :state => 'drafted'
    when /^(.*) account page$/i
      admin_user_path(Atreides::User.find_by_email($1))
    when /login/
      new_user_session_path
    when /logout/
      destroy_user_session_path
    when /the (.*) admin page/
      send "admin_#{$1}_path"

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(Atreides::User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)