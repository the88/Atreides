Factory.define :comment, :class => Atreides::Comment do |comment|
  comment.sequence(:title)  { |n| "Factory comment #{n}" }
  comment.comment           "This is as factory comment."
  # comment.commentable_id
  # comment.commentable_type
  # comment.user_id
  # comment.moderated_at
end

Factory.define :validated_comment, :class => Atreides::Comment, :parent => :comment do |comment|
  comment.moderated_at      1.minute.ago
end
