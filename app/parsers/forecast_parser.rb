class ForecastParser
  require 'date_helper'

  BASE_URL = 'https://api.forecast.io/forecast/74eab9bb995b47b2f881d969f05e5e3a/'

  attr_reader :params, :time, :parsed_response

  def initialize(params)
    @params = params
    @time = date_in_seconds_from(params[:date], params[:hour])
  end

  def parse_information
    @parsed_response = HTTParty.get("#{BASE_URL}#{build_url_params}").parsed_response
    parse_response
  end

  private

  def parse_response
    root = parsed_response['currently']
    {
      wind_speed: root['windSpeed'],
      precipitations: root['precipProbability'] != 0 ? 1 : 0,
      visibility: root['visibility'],
      humidity: root['humidity'],
      wind_bearing: root['windBearing'],
      temperature: root['temperature']
    }
  end

  def build_url_params
    "#{params[:lat]},#{params[:long]},#{time}"
  end
end
