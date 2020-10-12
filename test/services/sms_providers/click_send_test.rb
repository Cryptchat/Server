# frozen_string_literal: true

require 'test_helper'

class SmsProviders::ClickSendTest < ActiveSupport::TestCase
  setup do
    @instance = SmsProviders::ClickSend.new({
      username: 'ACdasdsad',
      api_key: 'dazasdasdasdasdasd',
      sender_id: '+966501234678'
    })
  end

  test '#initialize validates configs' do
    assert_raises(SmsProviders::InvalidConfig) do
      SmsProviders::ClickSend.new({})
    end
    assert_raises(SmsProviders::InvalidConfig) do
      SmsProviders::ClickSend.new({ username: 'ACdasdsad' })
    end
    assert_raises(SmsProviders::InvalidConfig) do
      SmsProviders::ClickSend.new({ username: 'ACdasdsad', api_key: 'dazasdasdasdasdasd' })
    end
    SmsProviders::ClickSend.new({
      username: 'ACdasdsad',
      api_key: 'dazasdasdasdasdasd',
      sender_id: '+966501234678'
    }) # shouldn't raise
  end

  test '#build_body builds request body correctly' do
    body = { "messages" => [{ "body" => "test sms", "from" => "+966501234678", "to" => "+966501234567" }] }
    stub_request(:post, "https://rest.clicksend.com/v3/sms/send")
      .with(
        body: body,
        headers: {
          'Authorization' => 'Basic QUNkYXNkc2FkOmRhemFzZGFzZGFzZGFzZGFzZA==',
          'Content-Type' => 'application/json'
        }
      )
      .to_return(status: 200, body: "", headers: {})

    @instance.send_sms(sms_content: 'test sms', to: '+966501234567')
    assert_equal(body, JSON.parse(@instance.build_body))
  end

  test '#build_headers builds request headers correctly' do
    body = { "messages" => [{ "body" => "test sms", "from" => "+966501234678", "to" => "+966501234567" }] }
    stub_request(:post, "https://rest.clicksend.com/v3/sms/send")
      .with(
        body: body,
        headers: {
          'Authorization' => 'Basic QUNkYXNkc2FkOmRhemFzZGFzZGFzZGFzZGFzZA==',
          'Content-Type' => 'application/json'
        }
      )
      .to_return(status: 200, body: "", headers: {})

    @instance.send_sms(sms_content: 'test sms', to: '+966501234567')
    assert_equal(
      {
        'Authorization' => 'Basic QUNkYXNkc2FkOmRhemFzZGFzZGFzZGFzZGFzZA==',
        'Content-Type' => 'application/json'
      },
      @instance.build_headers
    )
  end
end
