class Atreides::Comment < Atreides::Base

  acts_as_commentable

  #
  # Constants
  #

  #
  # Associatons
  #
  belongs_to :commentable, :polymorphic => true, :counter_cache => true
  belongs_to :user

  #
  # Validations
  #
  validates_presence_of :comment
  validate :spam_filter, :on => :create

  def spam_filter
    errors.add(:base, "Unfortunately this comment is considered spam by Akismet. It will show up once it has been approved by the administrator.") if spam?
  end

  #
  # Scopes
  #
  default_scope order('created_at ASC')
  scope :moderated, where("moderated_at is not null")
  scope :approved,  where("moderated_at is null")

  #
  # Callbacks
  #

  #
  # Class Methods
  #
  class << self
    def base_class
      self
    end
  end

  #
  # Instance Methods
  #
  def moderated?
    moderated_at?
  end

  def moderate!
    update_attributes!(:moderated_at => Time.zone.now)
  end

  def request=(request)
    @user_ip    = request.remote_ip
    @user_agent = request.env['HTTP_USER_AGENT']
    @referrer   = request.env['HTTP_REFERER']
    @has_request = true
  end

  def spam?
    result = @has_request ? Akismetor.spam?(akismet_attributes) : false
    moderate! if result
    result
  end

  def akismet_attributes
    {
      :key                  => 'abc123',
      :blog                 => "http://#{Settings.domain}",
      :user_ip              => @user_ip,
      :user_agent           => @user_agent,
      :comment_author       => user.full_name,
      :comment_author_email => user.email,
      # :comment_author_url   => site_url,
      :comment_content      => comment
    }
  end

  def mark_as_spam!
    moderate!
    Akismetor.submit_spam(akismet_attributes)
  end

  def mark_as_ham!
    update_attribute(:moderated_at, nil)
    Akismetor.submit_ham(akismet_attributes)
  end

  include Atreides::Extendable
end