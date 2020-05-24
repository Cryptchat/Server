# frozen_string_literal: true
class EphemeralKeysController < ApplicationController
  def top_up
    keys = params.require(:keys)
    unless Array === keys
      return render json: { messages: [I18n.t("keys_param_must_string_array")] }, status: 422
    end

    # user = current_user
    user = User.find_by(id: params.require(:user_id))
    count = user.ephemeral_keys.count
    if count + keys.size > Rails.configuration.user_ephemeral_keys_max_count
      return render json: { messages: [I18n.t("keys_count_exceeds_limit")] }, status: 403
    end

    user.add_ephemeral_keys!(keys)
    render json: {}, status: 200
  end
end
