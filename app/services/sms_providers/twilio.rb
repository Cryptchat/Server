# frozen_string_literal: true

class SmsProviders::Twilio < SmsProviders::Base
  def build_url
    account_sid = @configs[:account_sid]
    "https://api.twilio.com/2010-04-01/Accounts/#{account_sid}/Messages.json"
  end

  def build_headers
    auth_token = @configs[:auth_token]
    account_sid = @configs[:account_sid]

    base64 = Base64.strict_encode64("#{account_sid}:#{auth_token}")
    {
      'Authorization' => "Basic #{base64}",
      'Content-Type' => 'application/x-www-form-urlencoded',
      'Accept' => '*/*'
    }
  end

  def build_body
    from = @configs[:from]
    params = { From: from, Body: @sms_content, To: @to }
    # return params if Rails.env.test?
    Rack::Utils.build_query(params)
  end

  def configs_valid?
    @configs[:account_sid].present? &&
    @configs[:from].present? &&
    @configs[:auth_token].present?
  end
end
