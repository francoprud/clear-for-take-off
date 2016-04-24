module Api::V1::AirportsHelper

  def coordinates_by(airport_code)
    airports_coordinates[airport_code]
  end

  def aviation_wheather_code_by(airport_code)
    airports_aviation_weather_codes[airport_code]
  end

  def airport_tracks_by(airport_code)
    landing_tracks_by_airport[airport_code]
  end

  private

  def landing_tracks_by_airport
    {
      'KJFK' => [44, 44, 133.9, 133.9],
      'KEWR' => [40, 40, 110],
      'KPHL' => [80, 90, 90, 170],
      'KSFO' => [10, 10, 100, 100],
      'KLGA' => [40, 130],
      'KORD' => [40, 40, 90, 90, 100, 140, 140, 180]
    }
  end


  def airports_coordinates
    {
      'KJFK' => { 'lat' => 40.63972, 'long' => -73.77889 },
      'KEWR' => { 'lat' => 40.6925, 'long' => -74.16861 },
      'KPHL' => { 'lat' => 39.87194, 'long' => -75.24111 },
      'KSFO' => { 'lat' => 37.61889, 'long' => -122.375 },
      'KLGA' => { 'lat' => 40.77722, 'long' => -73.8725 },
      'KORD' => { 'lat' => 41.97861, 'long' => -87.90472 }
    }
  end

  #TODO: Set the correct station codes
  def airports_aviation_weather_codes
    {
      "KJFK" => "KORD",
      "KEWR" => "KDEN",
      "KPHL" => "KORD",
      "KSFO" => "KORD",
      "KLGA" => "KORD",
      "KORD" => "KORD"
    }
  end
end
