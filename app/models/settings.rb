# Provides access to configuration options stored in _config/settings.yml_
class Settings < Settingslogic
  source "#{Rails.root}/config/settings.yml"
  namespace Rails.env

  # Check if we can use an Amazon S3 bucket to store photos
  # @return true if the S3 gem and configuration is present, false otherwise
  def s3_enabled?
    !!(s3.access_key_id.present? && s3.secret_access_key.present? if respond_to? :s3)
  end

  def default_cross_post_to? service
    setting = Settings.default_cross_posts && Settings.default_cross_posts[service] # by default, if nothing specified in Settings.yml
    return true if setting.nil?
    setting
  end

  include Atreides::Extendable
end
