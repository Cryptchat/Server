require 'test_helper'

class MessagesControllerTest < ActionDispatch::IntegrationTest
  test "should create message" do
    body = "this is my secret message"
    sender = Fabricate(:user)
    receiver = Fabricate(:user)
    sender.save!
    receiver.save!
    assert_difference 'Message.count', 1 do
      post "/message.json", params: { message: { body: body, receiver_user_id: receiver.id, sender_user_id: sender.id } }
      assert_equal(200, response.status)
    end
    assert_equal(1, Message.where(body: body).count)
  end

  test "shouldn't create message when body or receiver are blank" do
    assert_no_difference 'Message.count' do
      post "/message.json", params: { message: { body: "" } }
    end
    assert_equal(422, response.status)
    json = JSON.parse(response.body)
    assert_includes(json["messages"], "Body can't be blank")
    assert_includes(json["messages"], "Receiver user can't be blank")
  end
end
