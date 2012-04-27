class Admin::Atreides::SessionsController < Devise::SessionsController

  layout 'admin'
  helper 'devise', 'atreides/admin', 'atreides/application'

  include Atreides::Extendable
end