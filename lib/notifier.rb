# frozen_string_literal: true

require 'net/http'

class Notifier
  FIREBASE_API_URI = URI("https://fcm.googleapis.com/fcm/send")
  SYNC_USERS_COMMAND = "sync_users"

  def initialize(user: nil, users: [], data:)
    @users = users.dup
    @users << user if user
    @data = data
  end

  def notify
    Asyncer.exec do
      headers = {
        "Content-Type" => "application/json",
        "Authorization" => "key=#{Rails.configuration.firebase[:server_key]}"
      }
      @users.each_slice(1000).each do |users|
        response = ::Net::HTTP.post(FIREBASE_API_URI, payload(users).to_json, headers)
        if response.code != "200"
          Rails.logger.error("Failed to send Firebase notification. #{response.inspect}\n#{response.body}")
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
