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
    forecast = forecasts.select { |f| Time.parse(f["fcst_time_from"]).utc.to_i < time && time < Time.parse(f["fcst_time_to"]).utc.to_i }.first
    forecast = forecasts.first unless forecast.present?
    response = {
      'wind_speed' => forecast['wind_speed_kt'].to_f,
      'visibility' => forecast['visibility_statute_mi'].to_f,
      'wind_bearing' => forecast['wind_dir_degrees'].to_f
    }
    response.merge!(calculate_sky_condition(forecast))
    response
  end

  # forecast['sky_condition'] if it has only one element returns as a hash, if it has more than one
  # element returns as an array of hashes
  def calculate_sky_condition(forecast)
    sky_conditions = forecast['sky_condition']
    if sky_conditions.present?
      if sky_conditions.class == Hash
        {
          'sky_cover' => sky_conditions['sky_cover'],
          'cloud_base' => sky_conditions['cloud_base_ft_agl']
        }
      else
        conditions = forecast['sky_condition'].select { |f| f['sky_cover'] == 'OVC' }
        if conditions.count == 0
          {
            'sky_cover' => sky_conditions.first['sky_cover'],
            'cloud_base' => sky_conditions.first['cloud_base_ft_agl']
          }
        else
          f = conditions.sort_by{ |h| h['cloud_base_ft_agl'].to_i }
          {
            'sky_cover' => f.first['sky_cover'],
            'cloud_base' => f.first['cloud_base_ft_agl']
          }
        end
      end
    else
      {
        'sky_cover' => 'Not available',
        'cloud_base' => 'Not available'
      }
    end
  end
end
