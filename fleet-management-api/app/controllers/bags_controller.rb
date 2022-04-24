# frozen_string_literal: true

class BagsController < ApplicationController
  before_action :set_bag, only: %i[show update destroy]

  # GET /bags
  def index
    @bags = Bag.all

    render json: @bags
  end

  # GET /bags/1
  def show
    render json: @bag
  end

  # POST /bags
  def create
    @bag = Bag.new(bag_params)

    if @bag.save
      render json: @bag, status: :created, location: @bag
    else
      render json: @bag.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /bags/1
  def update
    if @bag.update(bag_params)
      render json: @bag
    else
      render json: @bag.errors, status: :unprocessable_entity
    end
  end

  # DELETE /bags/1
  def destroy
    @bag.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_bag
    @bag = Bag.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def bag_params
    params.require(:bag).permit(:barcode, :status, :delivery_point_id)
  end
end
