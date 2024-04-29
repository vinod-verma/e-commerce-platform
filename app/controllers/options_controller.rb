class OptionsController < ApplicationController
  before_action :authorize_request

  def index
    @options  = Option.where(category_id: params[:category_id])
    render json: OptionSerializer.new(@options).serializable_hash, status: :ok
  end
end
