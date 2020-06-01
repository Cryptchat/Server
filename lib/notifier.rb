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
      @users.each_slice(1000).each do |users|
        res = ::Net::HTTP.post(uri, payload(users).to_json, headers)
        puts res
      end
    end
  end

  private

  def payload(users)
    instance_ids = users.map(&:instance_id)
    instance_id.compact!
    {
      registration_ids: instance_ids,
      data: @data
    }
  end
end
