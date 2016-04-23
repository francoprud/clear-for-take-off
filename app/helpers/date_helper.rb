module DateHelper
  def date_in_seconds_from(date_string, hour_string)
    #EXAMPLE: Time.new(2002, 10, 31, 2, 2, 2, "+02:00") #=> 2002-10-31 02:02:02 +0200
    year = date_string[0..3]
    month = date_string[4..5]
    day = date_string [6..7]
    hour = hour_string[0..1]
    minutes = hour_string[2..3]
    Time.new(year,month,day,hour,minutes)
  end
end
