# frozen_string_literal: true

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
    raise "Firebase Server Key is required" unless server_key
    @server_key = server_key
  end

  def notify
    Asyncer.exec do
      uri = URI(FIREBASE_API_URL)
      headers = {
        "Content-Type" => "application/json",
        "Authorization" => "key=#{@server_key}"
      }
      @users.each do |user|
        res = ::Net::HTTP.post(uri, payload(user).to_json, headers)
        puts res
      end
    end
  end

  private

  def payload(user)
    {
      registration_ids: [user.instance_id],
      data: @data.merge(secret_token: user.secret_token)
    }
  end
end
