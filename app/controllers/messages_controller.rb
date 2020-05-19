require 'net/http'

class MessagesController < ApplicationController
  # before_action :set_message, only: [:show, :update, :destroy]

  # POST /message
  # can't used send as the method name cuz that would override
  # ruby's send method.
  def transmit
    sender_user_id = Rails.env.development? ? 1 : message_params[:sender_user_id]
    receiver_user_id = Rails.env.development? ? 3 : message_params[:receiver_user_id]
    @message = Message.new(
      body: message_params[:body],
      sender_user_id: sender_user_id,
      receiver_user_id: receiver_user_id
    )

    if @message.save
      render success_response
      Asyncer.exec do
        uri = URI("https://fcm.googleapis.com/fcm/send")
        headers = {
          "Content-Type" => "application/json",
          "Authorization" => "key=#{ENV["API_KEY"]}"
        }
        payload = {
          registration_ids: [@message.sender.instance_id],
          data: {
            message: SecureRandom.hex
          }
        }
        res = ::Net::HTTP.post(uri, payload.to_json, headers)
        puts res
      end
    else
      render unprocessable_entity_response(@message.errors.full_messages)
    end
  end

  private

  # Only allow a trusted parameter "white list" through.
  def message_params
    params.require(:message).permit(:body, :receiver_user_id, :sender_user_id)
  end
end
