class Api::V1::WeathersController < ApplicationController
  def probability
    data = ForecastParser.new(params).parse_information
    render json: data, status: :ok

  end

  # date: yyyymmdd (format)
  # hour: hhmm (format)
  # airport_code: KJFK (example)
  def aviation_weather#(airport_origin_code, airport_destination_code, date, hour)
    #wired params for testing
    airport_origin_code = 'KJFK'
    airport_destination_code = 'KORD'
    date = '20160424'
    hour = '0325'
    #end of wired params

    url_for_origin = 'http://www.aviationweather.gov/adds/dataserver_current/httpparam?'
    url_for_origin << 'dataSource=tafs'
    url_for_origin << '&requestType=retrieve'
    url_for_origin << '&format=xml'
    url_for_origin << '&hoursBeforeNow=24'
    url_for_origin << '&mostRecent=true'
    url_for_origin << '&timeType=issue'
    url_for_origin << '&stationString='
    url_for_origin << (aviation_wheather_code_by airport_origin_code)
    response = ::HTTParty.get(url_for_origin).parsed_response

    render json: {}, status: :ok
  end
end
