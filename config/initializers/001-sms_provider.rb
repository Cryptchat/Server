# frozen_string_literal: true

sms_provider = ENV['CRYPTCHAT_SMS_PROVIDER']
sms_provider = 'twilio' if sms_provider.blank?
config_file = "#{Rails.root}/config/#{sms_provider}.yml"
raise "SMS provider config is not found in #{config_file}" if !File.exists?(config_file)
sms_configs = YAML.load(
  ERB.new(YAML.load_file(config_file)[Rails.env].to_yaml).result
)
Rails.application.config.sms_provider = sms_provider
Rails.application.config.sms_provider_configs = sms_configs
SmsProviders.instance if !Rails.env.test? # to make sure configs are verified at boot time
