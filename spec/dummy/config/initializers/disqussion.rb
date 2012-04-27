require 'disqussion'

Disqussion.configure do |config|
  config.api_key = Settings.disqus.key
  config.api_secret = Settings.disqus.secret
  # config.adapter = :em_synchrony
end

Disqussion::Posts.class_eval %Q{
  class << self
    def columns_hash
      a = {}
      self.column_names.each do |key|
        a.merge! key.to_sym => String
      end
      a
    end
    
    def column_names
      ["isJuliaFlagged","isFlagged","forum","parent","media","isApproved","dislikes","raw_message","isSpam","thread","points","createdAt","message","isHighlighted","ipAddress","id","isDeleted","likes","author"]
    end
  end
}

require 'hashie/rash'
Hashie::Rash.class_eval %Q{
  def dom_id(prefix)
    prefix + "_" + self.id
  end
}