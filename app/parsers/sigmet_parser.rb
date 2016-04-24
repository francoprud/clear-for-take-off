class SigmetParser
  include DateHelper
  include Api::V1::AirportsHelper
  attr_reader :params, :time, :parsed_response

  def initialize(parameters)
    @params = parameters
  end

  def parse_information
    url = "https://www.aviationweather.gov/adds/dataserver_current/httpparam?dataSource=airsigmets&requestType=retrieve&format=xml&flightPath=57.5"
    url << ';'
    url << (aviation_weather_code_by @params['origin'])
    url << ';'
    url <<  (aviation_weather_code_by @params['destination'])
    @sigmet_response = ::HTTParty.get(url).parsed_response
    parse_response
  end

  private

  def parse_response
    root = {}
  end

end
