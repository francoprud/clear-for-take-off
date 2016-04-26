class Api::V1::WeathersController < ApplicationController
  include Api::V1::AirportsHelper
  include DateHelper

  def probability
    time = date_in_seconds_from(params[:date], params[:hour])
    flight_time = calculate_flight_time.round
    if time <= (Time.zone.now + 6.hours).to_i
      byebug
      # SIGMET
      data_sigmet = SigmetParser.new(params[:origin], time).parse_information
      worst_prob = calculate_sigmet_probability(data_sigmet)

      unless worst_prob.present?
        data_origin = AviationWeatherParser.new(params, params[:origin], time).parse_information
        data_origin_more = ForecastParser.new(params, params[:origin], time).parse_information

        data_destiny = AviationWeatherParser.new(params, params[:destiny], time + flight_time).parse_information
        data_destiny_more = ForecastParser.new(params, params[:destiny], time + flight_time).parse_information

        data_origin_merge = data_merge(data_origin_more, data_origin)
        data_destiny_merge = data_merge(data_destiny_more, data_destiny)

        prob_origin = calculate_all_airport_tracks_probability(data_origin_merge, params[:origin])
        prob_destiny = calculate_all_airport_tracks_probability(data_destiny_merge, params[:destiny])
        worst_prob = calculate_worst_probability(prob_origin, prob_destiny)
      end
      render json: worst_prob, status: :ok
    elsif time <= (Time.zone.now + 24.hours).to_i
      # TAF
      data_origin = AviationWeatherParser.new(params, params[:origin], time).parse_information
      data_origin_more = ForecastParser.new(params, params[:origin], time).parse_information
      if (flight_time + time) <= (Time.zone.now + 24.hours).to_i
        data_destiny = AviationWeatherParser.new(params, params[:destiny], time + flight_time).parse_information
      else
        data_destiny = ForecastParser.new(params, params[:destiny], time + flight_time).parse_information
      end
      data_destiny_more = ForecastParser.new(params, params[:destiny], time + flight_time).parse_information

      data_origin_merge = data_merge(data_origin_more, data_origin)
      data_destiny_merge = data_merge(data_destiny_more, data_destiny)

      prob_origin = calculate_all_airport_tracks_probability(data_origin_merge, params[:origin])
      prob_destiny = calculate_all_airport_tracks_probability(data_destiny_merge, params[:destiny])
      worst_prob = calculate_worst_probability(prob_origin, prob_destiny)

      render json: worst_prob, status: :ok
    else
      data_origin = ForecastParser.new(params, params[:origin], time).parse_information
      data_destiny = ForecastParser.new(params, params[:destiny], time + flight_time).parse_information
      prob_origin = calculate_all_airport_tracks_probability(data_origin, params[:origin])
      prob_destiny = calculate_all_airport_tracks_probability(data_destiny, params[:destiny])
      worst_prob = calculate_worst_probability(prob_origin, prob_destiny)

      render json: worst_prob, status: :ok
    end
  end


  private

  def calculate_sigmet_probability(data)
    if data['sigmets']
      {
        'probability' => 5,
        'source' => 'origin',
        'reasons' => 'Extreme conditions around the airport area (SIGMET)'
      }
    end
  end

  # Overrides data1 values
  def data_merge(data1, data2)
    data1.merge(data2)
  end

  def calculate_flight_time
    calculate_airports_distances(params[:origin], params[:destiny]) / 200 # its the average plane speed
  end

  def calculate_airports_distances(airport1_code, airport2_code)
    air1 = coordinates_by(airport1_code)
    air2 = coordinates_by(airport2_code)
    calculate_distances(air1['lat'], air1['long'], air2['lat'], air2['long'])
  end

  def calculate_distances(lat1, long1, lat2, long2)
    earth_radius = 6371000 # in meters
    lat1_rad = lat1 * Math::PI / 180
    lat2_rad = lat2 * Math::PI / 180
    dlat = (lat2 - lat1) * Math::PI / 180
    dlong = (long2 - long1) * Math::PI / 180

    a = (Math.sin(dlat/2.0) ** 2) + (Math.sin(dlong/2.0) ** 2) * Math.cos(lat1_rad) * Math.cos(lat2_rad)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    earth_radius * c
  end

  def calculate_worst_probability(origin, destiny)
    if origin[0] >= destiny[0]
      {
        'probability' => origin[0],
        'source' => 'origin',
        'reasons' => (origin[0] == 1 || origin[0] == 2) ? 'No extreme weather conditions' : convert_into_sentence(origin[1])
      }
    else
      {
        'probability' => destiny[0],
        'source' => 'destiny',
        'reasons' => (destiny[0] == 1 || destiny[0] == 2) ? 'No extreme weather conditions' : convert_into_sentence(destiny[1])
      }
    end
  end

  def convert_into_sentence(reasons)
    ans = ""
    reasons.each_with_index do |v, i|
      if i == 0
        ans += v.capitalize
      elsif i < reasons.count - 1
        ans += ", #{v}"
      else
        ans += " and #{v}"
      end
    end
    "#{ans}"
  end

  def calculate_all_airport_tracks_probability(data, airport_code)
    responses = []
    airport_tracks_by(params[:origin]).each do |track|
      responses << calculate_probability(data, track)
    end
    sum = 0
    responses.each { |p| sum += p[:probability] }
    (sum / responses.count.to_f).round
    max = 0
    final_responses = []
    responses.each do |response|
      if (response[:probability] >= max)
        final_responses = [] if response[:probability] > max
        final_responses << response[:reasons]
        max = response[:probability]
      end
    end
    [max, final_responses.flatten.uniq]
  end

  def calculate_probability(data, track)
    reasons = []
    max_probability = 0
    wind = (data['wind_speed'] * Math.sin((track - data['wind_bearing']) * Math::PI / 180)).abs

    # Rule 1
    if (data['precipitations'] == 0 && wind < 25)
      if (max_probability <= 1)
        reasons = [] if max_probability < 1
        reasons << 'no precipitations'
        reasons << 'some winds'
        max_probability = 1
      end
    end

    # Rule 2
    if (data['precipitations'] == 0 && wind >= 25 && wind < 34)
      if (max_probability <= 2)
        reasons = [] if max_probability < 2
        reasons << 'no precipitations'
        reasons << 'extreme winds'
        max_probability = 2
      end
    end

    # Rule 3
    if (data['precipitations'] == 0 && wind >= 34)
      if (max_probability <= 5)
        reasons = [] if max_probability < 5
        reasons << 'no precipitations'
        reasons << 'medium winds'
        max_probability = 5
      end
    end

    # Rule 4
    if (data['precipitations'] == 1 && wind < 15)
      if (max_probability <= 1)
        reasons = [] if max_probability < 1
        reasons << 'precipitations'
        reasons << 'slow winds'
        max_probability = 1
      end
    end

    # Rule 5
    if (data['precipitations'] == 1 && wind >= 15 && wind < 25)
      if (max_probability <= 3)
        reasons = [] if max_probability < 3
        reasons << 'precipitations'
        reasons << 'some winds'
        max_probability = 3
      end
    end

    # Rule 6
    if (data['precipitations'] == 1 && wind > 25)
      if (max_probability <= 5)
        reasons = [] if max_probability < 5
        reasons << 'precipitations'
        reasons << 'extreme winds'
        max_probability = 5
      end
    end

    # Rule 7
    if (data['visibility'] < (meters_to_miles 150))
      if (max_probability <= 5)
        reasons = [] if max_probability < 5
        reasons << 'low visibility'
        max_probability = 5
      end
    end

    # Rule 8
    if (data['visibility'] >= (meters_to_miles 150) && data['visibility'] < (meters_to_miles 175) && wind < 25)
      if (max_probability <= 3)
        reasons = [] if max_probability < 3
        reasons << 'medium visibility'
        reasons << 'some winds'
        max_probability = 3
      end
    end

    # Rule 9
    if (data['visibility'] >= (meters_to_miles 150) && data['visibility'] < (meters_to_miles 175) && wind >= 25 && wind < 34)
      if (max_probability <= 4)
        reasons = [] if max_probability < 4
        reasons << 'medium visibility'
        reasons << 'some winds'
        max_probability = 4
      end
    end

    # Rule 10
    if (data['visibility'] >= (meters_to_miles 175) && data['visibility'] < (meters_to_miles 200) && wind < 25)
      if (max_probability <= 2)
        reasons = [] if max_probability < 2
        reasons << 'medium visibility'
        reasons << 'slow winds'
        max_probability = 2
      end
    end

    # Rule 11
    if (data['visibility'] >= (meters_to_miles 175) && data['visibility'] < (meters_to_miles 200) && wind >= 25 && wind < 34)
      if (max_probability <= 3)
        reasons = [] if max_probability < 3
        reasons << 'medium visibility'
        reasons << 'some winds'
        max_probability = 3
      end
    end

    # Rule 12
    if (data['visibility'] >= (meters_to_miles 200))
      if (max_probability <= 1)
        reasons = [] if max_probability < 1
        reasons << 'high visibility'
        max_probability = 1
      end
    end

    # Rule 13
    if (data['humidity'] == 100 && data['precipitations'] == 0 && data['temperature'] >= 23 && data['temperature'] <= 41)
      if (max_probability <= 4)
        reasons = [] if max_probability < 4
        reasons << 'high humidity'
        reasons << 'no precipitations'
        reasons << 'low temperatures'
        max_probability = 4
      end
    end

    # Rule 14
    if (data['humidity'] == 100 && data['precipitations'] == 1)
      if (max_probability <= 1)
        reasons = [] if max_probability < 1
        reasons << 'high humidity'
        reasons << 'precipitations'
        max_probability = 1
      end
    end

    # Rule 15
    if (data['humidity'] >= 80 && data['humidity'] < 100 && data['temperature'] >= 23 && data['temperature'] <= 41)
      if (max_probability <= 2)
        reasons = [] if max_probability < 2
        reasons << 'medium humidity'
        reasons << 'low temperatures'
        max_probability = 2
      end
    end

    {
      probability: max_probability,
      reasons: reasons.uniq
    }
  end

  def meters_to_miles(meters)
    meters*0.000621371
  end
end
