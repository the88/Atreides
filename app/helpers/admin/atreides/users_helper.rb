module Admin::Atreides::UsersHelper

  def name_column(user)
    link_to user.full_name, admin_user_path(user)
  end

  include Atreides::Extendable
end
