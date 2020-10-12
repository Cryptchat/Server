# frozen_string_literal: true

class SmsProviders::Base
  def initialize(configs)
    @configs = configs
    raise SmsProviders::InvalidConfig.new(configs) if !configs_valid?
  end

  def send_sms(sms_content:, to:)
    raise ArgumentError.new("sms content must be present") if sms_content.blank?
    raise ArgumentError.new("sms receiver must be present") if to.blank?

    @sms_content = sms_content
    @to = to

    url = build_url
    body = build_body
    headers = build_headers

    Rails.logger.debug("Sending SMS message to #{to.inspect}, url=#{url.inspect}, body=#{body.inspect}, headers=#{headers.inspect}")
    response = ::Net::HTTP.post(URI(url), body || "", headers || {})
    Rails.logger.debug(response.inspect)
    Rails.logger.debug(response.body)
    if response.code.to_i > 299
      Rails.logger.error("Failed to send sms message. #{response.inspect} #{response.body}")
    end
  end

  def build_url
    raise NotImplementedError.new("build_url is not implemented")
  end

  def build_headers
    raise NotImplementedError.new("build_headers is not implemented")
  end

  def build_body
    raise NotImplementedError.new("build_body is not implemented")
  end

  def configs_valid?
    raise NotImplementedError.new("configs_valid? is not implemented")
  end
end
