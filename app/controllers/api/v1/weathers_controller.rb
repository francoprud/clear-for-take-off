class Api::V1::WeathersController < ApplicationController
  def probability
    data = ForecastParser.new(params).parse_information



    #wired params for testing
    #testData = {
    #  airport_origin_code: 'KJFK',
    #  airport_destination_code: 'KORD',
    #  date: '20160424',
    #  hour: '0325'
    #}
    #end of wired params


    data2 = AviationWeatherParser.new(params).parse_information

    data3 = SigmetParser.new(params).parse_information
    render json: data, status: :ok

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

  def calculate_probability(data)
    reasons = []
    max_probability = 0
    # wind = (data['wind_speed'] * Math.sin(data['wind_bearing'] * )).abs
    wind = data['wind_speed'] # TODO: Calculate speed of wind with direction

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
    if (data['humidity'] == 100 && data['precipitations'] == 0 && data['temperature'] >= -5 && data['temperature'] <= 5)
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
    if (data['humidity'] >= 80 && data['humidity'] < 100 && data['temperature'] >= -5 && data['temperature'] <= 5)
      if (max_probability <= 2)
        reasons = [] if max_probability < 2
        reasons << 'medium humidity'
        reasons << 'low temperatures'
        max_probability = 2
      end
    end

    {
      probability: max_probability,
      reasons: reasons.unique
    }
  end
end
