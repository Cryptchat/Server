# frozen_string_literal: true

module SmsProviders
  class UnknownProvider < StandardError; end
  class InvalidConfig < StandardError; end

  PROVIDERS = {
    twilio: "SmsProviders::Twilio",
    click_send: "SmsProviders::ClickSend"
  }.freeze

  def self.instance
    return @klass.new(@configs) if @klass && @configs
    name = Rails.application.config.sms_provider&.to_sym
    klass = PROVIDERS[name]
    raise UnknownProvider.new("Unknown provider #{name}") if !klass
    @configs = Rails.application.config.sms_provider_configs
    @klass = klass.constantize
    @klass.new(@configs)
  end
end
