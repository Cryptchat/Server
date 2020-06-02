# frozen_string_literal: true

require 'net/http'

class Notifier
  FIREBASE_API_URL = "https://fcm.googleapis.com/fcm/send"

  def initialize(
    user: nil,
    users: [],
    data:,
    server_key: ENV["CRYPTCHAT_FIREBASE_SERVER_KEY"]
  )
    @users = users.dup
    @users << user if user
    @data = data
    @server_key = server_key
  end

  def notify
    Asyncer.exec do
      uri = URI(FIREBASE_API_URL)
      headers = {
        "Content-Type" => "application/json",
        "Authorization" => "key=#{@server_key}"
      }
      @users.each_slice(1000).each do |users|
        response = ::Net::HTTP.post(uri, payload(users).to_json, headers)
        if response.code != "200"
          Rails.logger.error("Failed to send Firebase notification. #{response.inspect}")
        end
      end
    end
  end

  private

  def payload(users)
    instance_ids = users.map(&:instance_id)
    instance_ids.compact!
    {
      registration_ids: instance_ids,
      data: @data
    }
  end
end
