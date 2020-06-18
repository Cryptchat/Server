# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]
  before_action :ensure_logged_in

  def sync
    # updated_at param unit is ms since epoch
    updated_at = params[:updated_at]&.to_i || 0
    users = User.where("FLOOR(EXTRACT(EPOCH FROM updated_at) * 1000) > ? AND id <> ?", updated_at, current_user.id)
    render json: users
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

  # Only allow a trusted parameter "white list" through.
  def user_params
    params.require(:user).permit(:country_code, :phone_number, :instance_id)
  end
end
