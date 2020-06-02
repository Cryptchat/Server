# frozen_string_literal: true

class MessagesController < ApplicationController
  class InvalidOptionalParams < StandardError; end

  # before_action :set_message, only: [:show, :update, :destroy]

  # POST /message
  # can't use send as the method name cuz that would override
  # ruby's send method.
  def transmit
    validate_optional_params!
    # message_params.merge!(sender_user_id: current_user.id)
    @message = Message.new(message_params)
    if @message.save
      notifier = Notifier.new(
        user: @message.receiver,
        data: {
          command: "sync_messages"
        }
      )
      notifier.notify
      render json: { message: { id: @message.id } }, status: 200
    else
      render unprocessable_entity_response(@message.errors.full_messages)
    end
  rescue InvalidOptionalParams => ex
    render unprocessable_entity_response(ex.message)
  end

  private

  def validate_optional_params!
    sepk = message_params[:sender_ephemeral_public_key]&.to_s
    ekioud = message_params[:ephemeral_key_id_on_user_device]&.to_i
    if sepk.present? && (ekioud.blank? || ekioud <= 0)
      raise InvalidOptionalParams.new(
        I18n.t("sepk_present_but_not_ekioud")
      )
    end
    if (ekioud.present? && ekioud >= 0) && sepk.blank?
      raise InvalidOptionalParams.new(
        I18n.t("ekioud_present_but_not_sepk")
      )
    end
  end

  # Only allow a trusted parameter "white list" through.
  def message_params
    return @message_params if @message_params

    params.require(:message).require([
      :body,
      :mac,
      :iv,
      :receiver_user_id,
      :sender_user_id
    ])
    @message_params ||= params.require(:message).permit(
      :body,
      :mac,
      :iv,
      :receiver_user_id,
      :sender_user_id, # TODO: remove when we have current user
      :sender_ephemeral_public_key,
      :ephemeral_key_id_on_user_device
    )
  end
end
