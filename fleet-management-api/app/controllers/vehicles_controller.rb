class VehiclesController < ApplicationController
  before_action :set_vehicle, only: [:show, :update, :destroy]
  before_action :snake_case_params

  attr_reader :delivery_point

  # GET /vehicles
  def index
    @vehicles = Vehicle.all

    render json: @vehicles
  end

  # GET /vehicles/1
  def show
    render json: @vehicle
  end

  # POST /vehicles
  def create
    @vehicle = Vehicle.new(vehicle_params)

    if @vehicle.save
      render json: @vehicle, status: :created, location: @vehicle
    else
      render json: @vehicle.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /vehicles/1
  def update
    if @vehicle.update(vehicle_params)
      render json: @vehicle
    else
      render json: @vehicle.errors, status: :unprocessable_entity
    end
  end

  # DELETE /vehicles/1
  def destroy
    @vehicle.destroy
  end

  def load_and_unload_shipments
    vehicle = Vehicle.find_by(plate: load_shipments_params[:plate])
    all_shipments = []
    if vehicle.nil?
      render json: {error: "Vehicle not found"}, status: :not_found
    else
      shipments_info = load_shipments_params.deep_symbolize_keys

      vehicle.transaction do
        shipments_info[:route].each do |r|
          @delivery_point = DeliveryPoint.find(r[:delivery_point])
          if delivery_point.nil?
            render json: {error: "Delivery point not found"}, status: :not_found
          else
            r[:deliveries].each do |delivery|

              # Q: what if package is already puts in a bag? # Duplicate problem ????
              barcode = delivery[:barcode]
              bag_shipment = Bag.find_by(barcode: barcode)
              package_shipment =  Package.find_by(barcode: barcode)
              
              # Load and then unload shipments
              if bag_shipment.present?
                bag_shipment.load
                bag_shipment.unload(@delivery_point)
                delivery.merge!(:state => bag_shipment.state)
              end
              
              if package_shipment.present?
                package_shipment.load
                package_shipment.unload(@delivery_point)
                delivery.merge!(:state => package_shipment.state)
              end
            end
          end
        end
      end
    
      render json: shipments_info
      
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vehicle
      @vehicle = Vehicle.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def vehicle_params
      params.require(:vehicle).permit(:plate)
    end

    def load_shipments_params
      params.permit(:plate, route: [
        :delivery_point,
        deliveries: [
          :barcode
        ]
      ]).to_h
    end
   
    def snake_case_params
			request.parameters.deep_transform_keys!(&:underscore)
		end
end
