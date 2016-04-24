class Api::V1::WeathersController < ApplicationController
  def probability
    data = ForecastParser.new(params).parse_information



    #wired params for testing
    #testData = {
    #  airport_origin_code: 'KJFK',
    #  airport_destination_code: 'KORD',
    #  date: '20160424',
    #  hour: '0325'
    #}
    #end of wired params


    data2 = AviationWeatherParser.new(params).parse_information
    byebug
    render json: data, status: :ok

  end

  # date: yyyymmdd (format)
  # hour: hhmm (format)
  # airport_code: KJFK (example)
  def aviation_weather#(airport_origin_code, airport_destination_code, date, hour)
    #wired params for testing
    testData = {
      airport_origin_code: 'KJFK',
      airport_destination_code: 'KORD',
      date: '20160424',
      hour: '0325'
    }
    #end of wired params

    data = AviationWeatherParser.new(testData).parse_information
    render json: data, status: :ok
  end
end
