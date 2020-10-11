# frozen_string_literal: true

require 'test_helper'

class SmsProviders::BaseTest < ActiveSupport::TestCase
  setup do
    @child = Class.new(SmsProviders::Base) do
      def build_url
        "https://fakesmsprovider.com/?to=#{@to}&body=#{@sms_content}"
      end

      def build_headers
        {
          Authorization: @configs[:auth_token]
        }
      end

      def build_body
        {
          to: @to,
          body: @sms_content
        }.to_json
      end

      def configs_valid?
        @configs.size > 0
      end
    end
    @instance = @child.new({ auth_token: 'xzcsdasdsa' })
  end

  test '#initialize validates config' do
    assert_raises(SmsProviders::InvalidConfig) do
      @child.new({})
    end
    @child.new({ key: 1 }) # should not raise
  end

  test '#send_sms validates arguments' do
    assert_raises(ArgumentError) do
      @instance.send_sms(sms_content: nil, to: nil)
    end
    assert_raises(ArgumentError) do
      @instance.send_sms(sms_content: '', to: '')
    end
    assert_raises(ArgumentError) do
      @instance.send_sms(sms_content: 'dsdsd', to: '')
    end
    assert_raises(ArgumentError) do
      @instance.send_sms(sms_content: '', to: 'xczxc')
    end
  end

  test '#send_sms makes POST request' do
    stub_request(:post, "https://fakesmsprovider.com/?body=hello%20this%20is%20test&to=%20966012345678")
      .with(
        body: "{\"to\":\"+966012345678\",\"body\":\"hello this is test\"}",
        headers: {
          'Authorization' => 'xzcsdasdsa',
        })
      .to_return(status: 200, body: "", headers: {})

    @instance.send_sms(sms_content: 'hello this is test', to: '+966012345678')
  end
end
