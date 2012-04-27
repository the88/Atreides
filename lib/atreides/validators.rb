# Custom validator checking for an email address
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value) #:nodoc:
    record.errors[attribute] << (options[:message] || "is not an email") unless
      value =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  end
end

# Custom validator checking for an URL
class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value) #:nodoc:
    record.errors[attribute] << (options[:message] || "is not a url") unless
      value =~ URI::regexp(%w(http https))
  end
end
