Factory.define :site, :class => Atreides::Site do |site|
  site.sequence(:name)  { |n| "site-#{n}" }
  site.created_at          5.minutes.ago
  site.updated_at          5.minutes.ago
  site.lang                I18n.locale
end
