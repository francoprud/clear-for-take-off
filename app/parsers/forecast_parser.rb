class ForecastParser
  include DateHelper
  include Api::V1::AirportsHelper

  BASE_URL = 'https://api.forecast.io/forecast/74eab9bb995b47b2f881d969f05e5e3a/'

  attr_reader :params, :airport_code, :time, :parsed_response

  def initialize(params, airport_code, time)
    @params = params
    @airport_code = airport_code
    @time = time
  end

  def parse_information
    @parsed_response = HTTParty.get("#{BASE_URL}#{build_url_params}").parsed_response
    parse_response
  end

  private

  def parse_response
    root = parsed_response['currently']
    {
      'wind_speed' => root['windSpeed'],
      'wind_bearing' => root['windBearing'],
      'precipitations' => root['precipProbability'] != 0 ? 1 : 0,
      'visibility' => root['visibility'],
      'humidity' => root['humidity'] * 100,
      'temperature' => root['temperature'],
      'sky_cover' => 'No available',
      'cloud_base' => 'No available'
    }
  end

  def build_url_params
    coordinates = coordinates_by(airport_code)
    "#{coordinates['lat']},#{coordinates['long']},#{time}"
  end
end
