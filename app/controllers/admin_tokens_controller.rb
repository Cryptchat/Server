# frozen_string_literal: true

class AdminTokensController < ApplicationController
  before_action :ensure_logged_in

  def generate
    if current_user.admin
      token = AdminToken.create_for!(current_user)
      render json: { key: token.unhashed_token }, status: 200
    else
      raise ApplicationController::Unauthorized.new
    end
  end
end
