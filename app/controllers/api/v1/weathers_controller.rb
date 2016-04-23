class Api::V1::WeathersController < ApplicationController
  def forecast
    render json: {}, status: :ok
  end
end
