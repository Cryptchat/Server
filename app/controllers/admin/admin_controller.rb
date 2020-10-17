# frozen_string_literal: true

class Admin::AdminController < ActionController::Base
  ADMIN_TOKEN_HEADER = "Cryptchat-Admin-Token"
  ADMIN_ID_HEADER = "Cryptchat-Admin-Id"

  # before_action :ensure_admin
  layout 'admin'
  helper_method :current_admin

  def index
    redirect_to :admin_users, status: 301
  end

  protected

  def current_admin
    cookies_admin_lookup || headers_admin_lookup
  end

  def ensure_admin
    raise ActionController::RoutingError.new('not found') unless current_admin
  end

  private

  def cookies_admin_lookup
    token = cookies[ADMIN_TOKEN_HEADER]
    admin_id = cookies[ADMIN_ID_HEADER]&.to_i
    if token && admin_id
      AdminToken.lookup_admin(token, admin_id)
    end
  end

  def headers_admin_lookup
    token = request.headers[ADMIN_TOKEN_HEADER]
    admin_id = request.headers[ADMIN_ID_HEADER]&.to_i
    admin = AdminToken.lookup_admin(token, admin_id) if token && admin_id
    if admin
      cookies[ADMIN_TOKEN_HEADER] = token
      cookies[ADMIN_ID_HEADER] = admin_id
    end
    admin
  end
end
