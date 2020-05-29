# frozen_string_literal: true

require 'test_helper'

class MessagesControllerTest < ActionDispatch::IntegrationTest
  test "#transmit requires body, mac, iv and receiver_user_id" do
    sender = Fabricate(:user)
    receiver = Fabricate(:user)

    post "/message.json", params: { message: {} }
    assert_equal(400, response.status)
    error_message = "param is missing or the value is empty: "
    assert_equal(error_message + "message", response.parsed_body["messages"].first)

    message_params = {
      body: "this is my encrypted secret message",
      mac: SecureRandom.hex,
      iv: SecureRandom.hex,
      receiver_user_id: receiver.id,
      sender_user_id: sender.id
    }
    %i[body mac iv receiver_user_id].each do |param|
      post "/message.json", params: { message: message_params.slice(*(message_params.keys - [param])) }
      assert_equal(400, response.status)
      assert_equal(error_message + param.to_s, response.parsed_body["messages"].first)
    end
  end

  test "#transmit creates message" do
    sender = Fabricate(:user)
    receiver = Fabricate(:user)
    message_params = {
      body: "this is my encrypted secret message",
      mac: SecureRandom.hex,
      iv: SecureRandom.hex,
      receiver_user_id: receiver.id,
      sender_user_id: sender.id
    }
    post "/message.json", params: { message: message_params }
    assert_equal(200, response.status)
    message = Message.find(response.parsed_body["message"]["id"])
    assert_equal(message_params[:body], message.body)
    assert_equal(message_params[:mac], message.mac)
    assert_equal(message_params[:iv], message.iv)
    assert_equal(message_params[:receiver_user_id], message.receiver_user_id)
    assert_equal(message_params[:sender_user_id], message.sender_user_id)
  end

  test '#transmit optional params must be all present or none' do
    sender = Fabricate(:user)
    receiver = Fabricate(:user)
    message_params = {
      body: "this is my encrypted secret message",
      mac: SecureRandom.hex,
      iv: SecureRandom.hex,
      receiver_user_id: receiver.id,
      sender_user_id: sender.id
    }
    post "/message.json", params: {
      message: message_params.merge(sender_ephemeral_public_key: "pubkey")
    }
    assert_equal(422, response.status)
    assert_equal(I18n.t("sepk_present_but_not_ekioud"), response.parsed_body["messages"].first)

    post "/message.json", params: { 
      message: message_params.merge(ephemeral_key_id_on_user_device: 11)
    }
    assert_equal(422, response.status)
    assert_equal(I18n.t("ekioud_present_but_not_sepk"), response.parsed_body["messages"].first)

    post "/message.json", params: { 
      message: message_params.merge(
        sender_ephemeral_public_key: "pubkey",
        ephemeral_key_id_on_user_device: 11
      )
    }
    assert_equal(200, response.status)
    message = Message.find(response.parsed_body["message"]["id"])
    assert_equal(message_params[:body], message.body)
    assert_equal("pubkey", message.sender_ephemeral_public_key)
    assert_equal(11, message.ephemeral_key_id_on_user_device)
  end
end
