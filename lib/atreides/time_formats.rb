Time::DATE_FORMATS[:default] = "%d %B %Y %I:%M %p"
Time::DATE_FORMATS[:month_and_year] = "%B %Y"
Time::DATE_FORMATS[:short_ordinal] = lambda { |time| time.strftime("%B #{time.day.ordinalize}") }
Time::DATE_FORMATS[:month_and_day_ordinal] = "%d %b"
Time::DATE_FORMATS[:long_ordinal] = lambda { |time| 
	time.strftime("#{time.day.ordinalize}, %b %Y %I:%M %p (#{Time.zone.utc_offset==-18000 ? 'EST' : Time.zone.name})") 
}
Time::DATE_FORMATS[:date_ordinal] = lambda { |time| 
	time.strftime("%d %b '%y") 
}
Time::DATE_FORMATS[:long_date_ordinal] = lambda { |time| 
	time.strftime("%B #{time.day.ordinalize} %Y") 
}
Time::DATE_FORMATS[:datetime_ordinal] = lambda { |time| 
	time.strftime("%d %b '%y %I:%M %p") 
}
Time::DATE_FORMATS[:short_month_and_year] = "%b %Y"
Time::DATE_FORMATS[:month_and_day] = "%B %d"
Time::DATE_FORMATS[:day] = "%d"