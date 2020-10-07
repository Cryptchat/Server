# frozen_string_literal: true

module SmsProviders
  class UnknownProvider < StandardError; end
  class InvalidConfig < StandardError; end

  PROVIDERS = {
    twilio: "SmsProviders::Twilio"
  }.freeze

  def self.instance
    return @provider if @provider.present?

    name = Rails.application.config.sms_provider&.to_sym
    klass = PROVIDERS[name]
    raise UnknownProvider.new("Unknown provider #{name}") if !klass
    configs = Rails.application.config.sms_provider_configs
    @provider = klass.constantize.new(configs)
  end
end
