module PostOverrides
  extend ActiveSupport::Concern

  included do
    puts "Dummy Post concern included !"
  end

  module ClassMethods
    def hello
      "World ! (from Post.hello)".tap { |msg| puts msg }
    end
  end

  def greet
    "Hey you ! (from Post#greet)".tap { |msg| puts msg }
  end
end
