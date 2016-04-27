module DateHelper
  def date_in_seconds_from(date_string, hour_string, offset)
    year = date_string[0..3]
    month = date_string[4..5]
    day = date_string [6..7]
    hour = hour_string[0..1]
    minutes = hour_string[2..3]
    Time.new(year,month,day,hour,minutes, 0, offset).utc.to_i
  end

  def calculate_offset(offset)
    offset_in_hours = (offset.to_i / 60).round
    "#{offset_in_hours >= 0 ? '-' : '+'}#{offset_in_hours.abs >= 10 ? '' : '0'}#{offset_in_hours.abs}:00"
  end
end
