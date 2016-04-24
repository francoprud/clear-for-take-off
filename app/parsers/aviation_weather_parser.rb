class AviationWeatherParser
  include DateHelper
  include Api::V1::AirportsHelper
  attr_reader :params, :time, :parsed_response

  def initialize(parameters)
    @params = parameters
    @time = date_in_seconds_from(parameters[:date], parameters[:hour])
  end

  def parse_information
    url = 'http://www.aviationweather.gov/adds/dataserver_current/httpparam?'
    url << 'dataSource=tafs'
    url << '&requestType=retrieve'
    url << '&format=xml'
    url << '&hoursBeforeNow=24'
    url << '&mostRecent=true'
    url << '&timeType=issue'
    url << '&stationString='
    url_for_origin = url +  (aviation_wheather_code_by @params['origin'])
    url_for_destination = url + (aviation_wheather_code_by @params['destination'])
    @origin_parsed_response = ::HTTParty.get(url_for_origin).parsed_response
    @destination_parsed_response = ::HTTParty.get(url_for_destination).parsed_response
    parse_response
  end

  private

  def parse_response
    all_origin_forecast = @origin_parsed_response["response"]["data"]["TAF"]["forecast"]
    all_destination_forecast = @origin_parsed_response["response"]["data"]["TAF"]["forecast"]
    origin_forecast = all_origin_forecast.select { |f| Time.parse(f["fcst_time_from"]).to_i < utc_time && utc_time < Time.parse(f["fcst_time_to"]).to_i }.first
    destination_forecast = all_destination_forecast.select { |f| Time.parse(f["fcst_time_from"]).to_i < utc_time && utc_time < Time.parse(f["fcst_time_to"]).to_i }.first
    byebug
    responses = {
      "origin_response" => {
        wind_speed: origin_forecast['wind_speed_kt'],
        visibility: origin_forecast['visibility_statute_mi'],
        wind_bearing: origin_forecast['wind_dir_degrees'],
      },
      "destination_response" => {
          wind_speed: destination_forecast['wind_speed_kt'],
          visibility: destination_forecast['visibility_statute_mi'],
          wind_bearing: destination_forecast['wind_dir_degrees'],
        }
      }
  end

def utc_time
  @time - 60*60*3
end

end
