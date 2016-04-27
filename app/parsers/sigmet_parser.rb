class SigmetParser
  include DateHelper
  include Api::V1::AirportsHelper
  attr_reader :airport_code, :time, :sigmet_response

  BASE_URL = 'https://www.aviationweather.gov/adds/dataserver_current/httpparam?dataSource=airsigmets&requestType=retrieve&format=xml'

  def initialize(airport_code, time)
    @airport_code = airport_code
    @time = time
  end

  def parse_information
    @sigmet_response = ::HTTParty.get(build_url).parsed_response
    parse_response
  end

  private

  def parse_response
    severe_sigmets = sigmet_response['response']['data']['AIRSIGMET'].any? { |s| s['airsigmet_type'] == 'SIGMET' && s['hazard']['severity'] == 'SEV' }
    { 'sigmets' => severe_sigmets }
  end

  def valid_period
    now_in_secs = Time.new.utc.to_i
    (now_in_secs - (6*60*60) + (time - now_in_secs))  / 3600
  end

  def build_url
    airport_coordinates = coordinates_by(airport_code)
    url = BASE_URL
    url += "&minLat=#{airport_coordinates['lat'] - 0.5}"
    url += "&minLon=#{airport_coordinates['long'] - 0.5}"
    url += "&maxLat=#{airport_coordinates['lat'] + 0.5}"
    url += "&maxLon=#{airport_coordinates['lat'] + 0.5}"
    url += "&hoursBeforeNow=#{valid_period}"
  end
end
