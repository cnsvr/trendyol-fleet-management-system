# frozen_string_literal: true

class DeliveryPointsController < ApplicationController
  before_action :set_delivery_point, only: %i[show update destroy]

  # GET /delivery_points
  def index
    @delivery_points = DeliveryPoint.all

    render json: @delivery_points
  end

  # GET /delivery_points/1
  def show
    render json: @delivery_point
  end

  # POST /delivery_points
  def create
    @delivery_point = DeliveryPoint.new(delivery_point_params)

    if @delivery_point.save
      render json: @delivery_point, status: :created, location: @delivery_point
    else
      render json: @delivery_point.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /delivery_points/1
  def update
    if @delivery_point.update(delivery_point_params)
      render json: @delivery_point
    else
      render json: @delivery_point.errors, status: :unprocessable_entity
    end
  end

  # DELETE /delivery_points/1
  def destroy
    @delivery_point.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_delivery_point
    @delivery_point = DeliveryPoint.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def delivery_point_params
    params.require(:delivery_point).permit(:delivery_point, :value)
  end
end
