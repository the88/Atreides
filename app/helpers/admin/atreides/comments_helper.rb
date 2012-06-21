module Admin::Atreides::CommentsHelper

  def author_column(comment)
    comment.user ? comment.user.full_name : "Anonymous"
  end

  include Atreides::Extendable
end
