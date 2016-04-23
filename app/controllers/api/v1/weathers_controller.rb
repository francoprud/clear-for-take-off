class Api::V1::WeathersController < ApplicationController
  def forecast
    render json: {}, status: :ok
  end

  # date: yyyymmdd (format)
  # hour: hhmm (format)
  # airport_code: KJFK (example)
  def aviation_weather(airport_code, date, hour)
    #url = 'http://www.aviationweather.gov/adds/metars/?'
    #url << 'station_ids=' << (aviation_wheather_code_by airport_code)
    #response = ::HTTParty.get(url + '&std_trans=standard&chk_metars=on&hoursStr=most+recent+only&chk_tafs=on&format=xml&submitmet=Submit').parsed_response
    #byebug

    # WORK WITH response DATA
    render json: {}, status: :ok
  end

  private

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
