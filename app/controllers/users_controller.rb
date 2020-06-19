# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :ensure_logged_in

  def sync
    # updated_at param unit is ms since epoch
    updated_at = params[:updated_at]&.to_i || 0
    users = User.where("FLOOR(EXTRACT(EPOCH FROM updated_at) * 1000) > ? AND id <> ?", updated_at, current_user.id)
    render json: users
  end

  def update
    user = current_user
    if user.update(user_params)
      render success_response
    else
      render error_response(
        status: 422,
        messages: user.errors.full_messages
      )
    end
  end

  private

  # Only allow a trusted parameter "white list" through.
  def user_params
    params.require(:user).permit(
      :country_code,
      :phone_number,
      :instance_id,
      :name
    )
  end
end
