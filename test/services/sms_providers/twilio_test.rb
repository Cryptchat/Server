# frozen_string_literal: true

require 'test_helper'

class SmsProviders::TwilioTest < ActiveSupport::TestCase
  setup do
    @instance = SmsProviders::Twilio.new({
      account_sid: 'ACdasdsad',
      auth_token: 'dazasdasdasdasdasd',
      from: '+966501234678'
    })
  end

  test '#initialize validates configs' do
    assert_raises(SmsProviders::InvalidConfig) do
      SmsProviders::Twilio.new({})
    end
    assert_raises(SmsProviders::InvalidConfig) do
      SmsProviders::Twilio.new({ account_sid: 'ACdasdsad' })
    end
    assert_raises(SmsProviders::InvalidConfig) do
      SmsProviders::Twilio.new({ account_sid: 'ACdasdsad', auth_token: 'dazasdasdasdasdasd' })
    end
    SmsProviders::Twilio.new({
      account_sid: 'ACdasdsad',
      auth_token: 'dazasdasdasdasdasd',
      from: '+966501234678'
    }) # shouldn't raise
  end

  test '#build_url builds Twilio URL correctly' do
    assert_equal('https://api.twilio.com/2010-04-01/Accounts/ACdasdsad/Messages.json', @instance.build_url)
  end

  test '#build_body builds request body correctly' do
    stub_request(:post, "https://api.twilio.com/2010-04-01/Accounts/ACdasdsad/Messages.json")
      .with(
        body: { "Body" => "test sms", "From" => "+966501234678", "To" => "+966501234567" },
        headers: {
          'Accept'=>'*/*',
          'Authorization'=>'Basic QUNkYXNkc2FkOmRhemFzZGFzZGFzZGFzZGFzZA==',
          'Content-Type'=>'application/x-www-form-urlencoded',
        }
      )
      .to_return(status: 200, body: "", headers: {})

    @instance.send_sms(sms_content: 'test sms', to: '+966501234567')
    assert_equal('From=%2B966501234678&Body=test+sms&To=%2B966501234567', @instance.build_body)
  end

  test '#build_headers builds request headers correctly' do
    stub_request(:post, "https://api.twilio.com/2010-04-01/Accounts/ACdasdsad/Messages.json")
      .with(
        body: { "Body" => "test sms", "From" => "+966501234678", "To" => "+966501234567" },
        headers: {
          'Accept'=>'*/*',
          'Authorization'=>'Basic QUNkYXNkc2FkOmRhemFzZGFzZGFzZGFzZGFzZA==',
          'Content-Type'=>'application/x-www-form-urlencoded',
        }
      )
      .to_return(status: 200, body: "", headers: {})

    @instance.send_sms(sms_content: 'test sms', to: '+966501234567')
    assert_equal(
      {
        'Authorization' => 'Basic QUNkYXNkc2FkOmRhemFzZGFzZGFzZGFzZGFzZA==',
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Accept' => '*/*'
      },
      @instance.build_headers
    )
  end
end
