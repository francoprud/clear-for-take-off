class SigmetParser
  include DateHelper
  include Api::V1::AirportsHelper
  attr_reader :params, :time, :parsed_response

  def initialize(airport_code, time)
    @airport_code = airport_code
    @time = time
  end

  def parse_information

    airport_coordinates = coordinates_by @airport_code
    url = 'https://www.aviationweather.gov/adds/dataserver_current/httpparam?dataSource=airsigmets&requestType=retrieve&format=xml'

    url << '&minLat='
    url << (airport_coordinates['lat'] - 0.5).to_s
    url << '&minLon='
    url << (airport_coordinates['long'] - 0.5).to_s
    url << '&maxLat='
    url << (airport_coordinates['lat'] + 0.5).to_s
    url << '&maxLon='
    url << (airport_coordinates['lat'] + 0.5).to_s
    url << '&hoursBeforeNow='
    url << valid_period.to_s

    @sigmet_response = ::HTTParty.get(url).parsed_response
    parse_response
  end

  private

  def parse_response
    severe_sigmets = @sigmet_response['response']['data']['AIRSIGMET'].select { |c| c['airsigmet_type'] == 'SIGMET' && c['hazard']['severity'] == 'SEV' }
    hazard_count = severe_sigmets.count
    hazard_names = severe_sigmets.map { |c| c['hazard']['type']}.uniq
    {
      'count' => hazard_count,
      'names' => hazard_names
    }
  end

  def valid_period
    (@time - (@time - Time.new.utc.to_i).abs) *60 *60
  end

end
