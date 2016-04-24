module DateHelper
  def date_in_seconds_from(date_string, hour_string)
    year = date_string[0..3]
    month = date_string[4..5]
    day = date_string [6..7]
    hour = hour_string[0..1]
    minutes = hour_string[2..3]
    Time.new(year,month,day,hour,minutes, 0, "-02:00").utc.to_i
  end
end
