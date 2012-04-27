module PostsControllerOverrides
  extend ActiveSupport::Concern

  def greet
    "Hey you ! (from PostsController#greet)".tap { |msg| puts msg }
  end
end
