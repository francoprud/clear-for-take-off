class AviationWeatherParser
  include DateHelper
  include Api::V1::AirportsHelper
  attr_reader :params, :airport_code, :time, :parsed_response

  BASE_URL = 'http://www.aviationweather.gov/adds/dataserver_current/httpparam?'

  def initialize(params, airport_code, time)
    @params = params
    @airport_code = airport_code
    @time = time
  end

  def parse_information
    url = "#{BASE_URL}dataSource=tafs&requestType=retrieve&format=xml&hoursBeforeNow=24&mostRecent=true&timeType=issue&stationString=#{aviation_weather_code_by(airport_code)}"
    @parsed_response = ::HTTParty.get(url).parsed_response
    parse_response
  end

  private

  def parse_response
    forecasts = parsed_response['response']['data']['TAF']['forecast']
    forecast = forecasts.select { |f| Time.parse(f["fcst_time_from"]).to_i < utc_time && utc_time < Time.parse(f["fcst_time_to"]).to_i }.first
    {
      'wind_speed' => forecast['wind_speed_kt'].to_f,
      'visibility' => forecast['visibility_statute_mi'].to_f,
      'wind_bearing' => forecast['wind_dir_degrees'].to_f
    }
  end

  def utc_time
    @time - 60 * 60 * 3
  end
end
