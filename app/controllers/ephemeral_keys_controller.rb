# frozen_string_literal: true

class EphemeralKeysController < ApplicationController
  before_action :ensure_logged_in

  def top_up
    keys = params.permit([{ keys: [:id, :key] }])[:keys]
    if !(Array === keys) || keys.size == 0
      return render error_response(
        status: 422,
        message: I18n.t("keys_param_incorrect_format")
      )
    end
    keys.each do |k|
      k.require(%i[id key])
    end

    user = current_user
    count = user.ephemeral_keys.count
    if count + keys.size > Rails.configuration.user_ephemeral_keys_max_count
      return render error_response(
        status: 403,
        message: I18n.t("keys_count_exceeds_limit")
      )
    end

    user.add_ephemeral_keys!(keys)
    render json: {}, status: 200
  end

  def grab
    user = User.find_by(id: params.require(:user_id))
    return render error_response(
      status: 404,
      message: I18n.t("eph_key_grab_failed_user_not_found")
    ) unless user

    key = user.atomic_delete_and_return_ephemeral_key!
    render json: (key || {})
  end
end
