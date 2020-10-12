# frozen_string_literal: true

class SmsProviders::ClickSend < SmsProviders::Base
  def build_url
    "https://rest.clicksend.com/v3/sms/send"
  end

  def build_headers
    api_key = @configs[:api_key]
    username = @configs[:username]

    base64 = Base64.strict_encode64("#{username}:#{api_key}")
    {
      'Authorization' => "Basic #{base64}",
      'Content-Type' => 'application/json'
    }
  end

  def build_body
    sender_id = @configs[:sender_id]
    params = { from: sender_id, body: @sms_content, to: @to }
    { messages: [params] }.to_json
  end

  def configs_valid?
    @configs[:api_key].present? &&
    @configs[:username].present? &&
    @configs[:sender_id].present?
  end
end
