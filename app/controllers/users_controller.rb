class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /user/1
  def update
    if @user.update(user_params)
      render success_response
    else
      render unprocessable_entity_response(@user.errors.full_messages)
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:country_code, :phone_number, :instance_id)
    end
end
