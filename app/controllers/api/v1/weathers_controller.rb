class Api::V1::WeathersController < ApplicationController
  def probability
    data = ForecastParser.new(params).parse_information
    render json: data, status: :ok
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
end
