class AviationWeatherParser
  include DateHelper
  include Api::V1::AirportsHelper
  attr_reader :params, :time, :parsed_response

  def initialize(parameters)
    @params = parameters
    byebug
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
    byebug
    url_for_origin = url +  (aviation_wheather_code_by @params['origin'])
    url_for_destination = url + (aviation_wheather_code_by @params['destination'])
    @origin_parsed_response = ::HTTParty.get(url_for_origin).parsed_response
    @destination_parsed_response = ::HTTParty.get(url_for_destination).parsed_response
    parse_response
  end

  private

  def parse_response
    root = {} #parsed_response['currently']
    #{
    #  wind_speed: root['windSpeed'],
    #  precipitations: root['precipProbability'] != 0 ? 1 : 0,
    #  visibility: root['visibility'],
    #  humidity: root['humidity'],
    #  wind_bearing: root['windBearing'],
    #  temperature: root['temperature']
    #}
  end

end
