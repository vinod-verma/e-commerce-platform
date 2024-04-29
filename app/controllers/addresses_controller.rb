 class AddressesController < ApplicationController
  before_action :authorize_request
  before_action :set_address, only: [:show, :update, :destroy]

  def index
    addresses = @current_user.addresses
    render json: AddressSerializer.new(addresses).serializable_hash, status: :ok
  end

  def show
    render json: AddressSerializer.new(@address).serializable_hash, status: :ok
  end

  def create
    @address = @current_user.addresses.new(address_params)

    if @address.save
      render json: AddressSerializer.new(@address).serializable_hash, status: :ok
    else
      render json: { errors: @address.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def update
    if @address.update(address_params)
      render json: AddressSerializer.new(@address).serializable_hash, status: :ok
    else
      render json: { errors: @address.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def destroy
    if @address.destroy
      render json: { message: "Address removed from list." }, status: :ok
    else
      render json: { errors: @address.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  private
    def set_address
      @address = @current_user.addresses.find(params[:id])
    end

    def address_params
      params.require(:address).permit(:name, :phone, :pincode, :locality, :address, :city, :state, :landmark, :alt_phone, :address_type)
    end
end
