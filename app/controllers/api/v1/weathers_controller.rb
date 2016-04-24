class Api::V1::WeathersController < ApplicationController
  include Api::V1::AirportsHelper

  def probability
    data_origin = ForecastParser.new(params, params[:origin]).parse_information
    data_destiny = ForecastParser.new(params, params[:destiny]).parse_information
    prob_origin = calculate_all_airport_tracks_probability(data_origin, params[:origin])
    prob_destiny = calculate_all_airport_tracks_probability(data_destiny, params[:destiny])
    worst_prob = calculate_worst_probability(prob_origin, prob_destiny)

    # data2 = AviationWeatherParser.new(params).parse_information
    # data3 = SigmetParser.new(params).parse_information
    # render json: data, status: :ok

    render json: worst_prob, status: :ok
  end

  # date: yyyymmdd (format)
  # hour: hhmm (format)
  # airport_code: KJFK (example)
  def aviation_weather#(airport_origin_code, airport_destination_code, date, hour)
    #wired params for testing
    testData = {
      airport_origin_code: 'KJFK',
      airport_destination_code: 'KORD',
      date: '20160424',
      hour: '0325'
    }
    #end of wired params

    data = AviationWeatherParser.new(testData).parse_information
    render json: data, status: :ok
  end

  private

  def calculate_worst_probability(origin, destiny)
    if origin[0] >= destiny[0]
      {
        'probability' => origin[0],
        'source' => 'origin',
        'reasons' => convert_into_sentence(origin[1])
      }
    else
      {
        'probability' => destiny[0],
        'source' => 'destiny',
        'reasons' => convert_into_sentence(destiny[1])
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
    "#{ans}."
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
    wind = (data['wind_speed'] * Math.sin(track - data['wind_bearing'] * Math::PI / 180)).abs

    # Rule 1
    if (data['precipitations'] == 0 && wind < 25)
      if (max_probability <= 1)
        reasons = [] if max_probability < 1
        reasons << 'no precipitations'
        reasons << 'slow winds'
        max_probability = 1
      end
    end

    # Rule 2
    if (data['precipitations'] == 0 && wind >= 25 && wind < 34)
      if (max_probability <= 2)
        reasons = [] if max_probability < 2
        reasons << 'no precipitations'
        reasons << 'fast winds'
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
        reasons << 'medium winds'
        max_probability = 3
      end
    end

    # Rule 6
    if (data['precipitations'] == 1 && wind > 25)
      if (max_probability <= 5)
        reasons = [] if max_probability < 5
        reasons << 'precipitations'
        reasons << 'fast winds'
        max_probability = 5
      end
    end

    # Rule 7
    if (data['visibility'] < 150)
      if (max_probability <= 5)
        reasons = [] if max_probability < 5
        reasons << 'low visibility'
        max_probability = 5
      end
    end

    # Rule 8
    if (data['visibility'] >= 150 && data['visibility'] < 175 && wind < 25)
      if (max_probability <= 3)
        reasons = [] if max_probability < 3
        reasons << 'medium visibility'
        reasons << 'slow winds'
        max_probability = 3
      end
    end

    # Rule 9
    if (data['visibility'] >= 150 && data['visibility'] < 175 && wind >= 25 && wind < 34)
      if (max_probability <= 4)
        reasons = [] if max_probability < 4
        reasons << 'medium visibility'
        reasons << 'fast winds'
        max_probability = 4
      end
    end

    # Rule 10
    if (data['visibility'] >= 175 && data['visibility'] < 200 && wind < 25)
      if (max_probability <= 2)
        reasons = [] if max_probability < 2
        reasons << 'medium visibility'
        reasons << 'slow winds'
        max_probability = 2
      end
    end

    # Rule 11
    if (data['visibility'] >= 175 && data['visibility'] < 200 && wind >= 25 && wind < 34)
      if (max_probability <= 3)
        reasons = [] if max_probability < 3
        reasons << 'medium visibility'
        reasons << 'fast winds'
        max_probability = 3
      end
    end

    # Rule 12
    if (data['visibility'] >= 200)
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
end
