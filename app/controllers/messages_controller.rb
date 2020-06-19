# frozen_string_literal: true

class MessagesController < ApplicationController
  class InvalidOptionalParams < StandardError; end

  SYNC_MESSAGES_COMMAND = "sync_messages"

  before_action :ensure_logged_in

  # POST /message
  # can't use send as the method name cuz that would override
  # ruby's send method.
  def transmit
    validate_optional_params!
    message_params.merge!(sender_user_id: current_user.id)
    @message = Message.new(message_params)
    if @message.save
      notifier = Notifier.new(
        user: @message.receiver,
        data: {
          command: SYNC_MESSAGES_COMMAND
        }
      )
      notifier.notify
      render json: { message: { id: @message.id } }, status: 200
    else
      render error_response(
        status: 422,
        messages: @message.errors.full_messages
      )
    end
  rescue InvalidOptionalParams => ex
    render error_response(
      status: 422,
      message: ex.message
    )
  end

  def sync
    last_seen_id = params[:last_seen_id] || 0
    user_id = current_user.id
    messages = Message
      .where(receiver_user_id: user_id)
      .where("id > ?", last_seen_id)
      .order(:id)
      .limit(50)
    render json: messages, status: 200
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
      :receiver_user_id
    ])
    @message_params ||= params.require(:message).permit(
      :body,
      :mac,
      :iv,
      :receiver_user_id,
      :sender_ephemeral_public_key,
      :ephemeral_key_id_on_user_device
    )
  end
end
