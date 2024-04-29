class UsersController < ApplicationController
  before_action :authorize_request, except: :create

  def index
    @users = User.all
    render json: UserSerializer.new(@users).serializable_hash, status: :ok
  end

  def show
    render json: UserSerializer.new(@current_user).serializable_hash, status: :ok
  end

  def create
    @user = User.new(user_params)
    if @user.save
      token = JwtWebToken.encode(user_id: @user.id)
      time = Time.now + 24.hours.to_i
      render json: {
        token: token,
        exp: time.strftime("%m-%d-%Y %H:%M"),
        user: UserSerializer.new(@user).serializable_hash
      }, status: :created
    else
      render json: { errors: @user.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def update
    unless @current_user.update(user_params)
      return render json: { errors: @current_user.errors.full_messages },
             status: :unprocessable_entity
    end
    render json: UserSerializer.new(@current_user).serializable_hash, status: :ok
  end

  def destroy
    if @current_user.destroy
      render json: {user: "#{@current_user.email} destroyed successfully"}, status: :ok
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :gender, :phone, :email, :password
    )
  end
end
